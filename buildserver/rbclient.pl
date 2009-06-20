#!/usr/bin/perl -s

#use strict;
use IO::Socket;
use IO::Select;
use IO::File;
use IO::Pipe;
use File::Basename;
use POSIX 'mkfifo';
use POSIX ":sys_wait_h";

my $upload = "http://192.168.1.10/b/upload.pl";
my $cwd = `pwd`;
chomp $cwd;

my $clientver = 1;
my $username = "foobar";
my $password = "master";
my $clientname = $clientname || "laptop-".$$;

unless ($archlist) {
    print "You must specify -archlist. Example:\nperl rbclient.pl -archlist=sh,arm,m68k,linuxsim\n";
    exit;
}

#&testarchs();

my $sock;

beginning:

while (1) {
    $sock = IO::Socket::INET->new(PeerAddr => '192.168.1.10',
                                  PeerPort => 19999,
                                  Proto    => 'tcp',
                                  Blocking => 0)
        or die "$!";
    
    last if ($sock->connected);

    print "Waiting for server connection\n";
    sleep 1;
}


# Add the master socket to select mask
my $read_set = new IO::Select();
$read_set->add($sock);
$conntype{$sock->fileno} = 'socket';

my $auth = "$username:$password";
my ($speed, $cores) = &bogomips;
my $cpu = `uname -m`;
chomp $cpu;
my $os = `uname -o`;
chomp $os;

print $sock "HELLO $clientver $archlist $auth $clientname $cpu 32 $os $speed\n";

my $busy = 0;
my %builds = ();
my $buildnum = 0;

# Mail loop active until ^C pressed
my $done = 0;
#$SIG{INT} = sub { warn "received interrupt\n"; $done = 1; };

while (not $done) {
    my ($rh_set, $timeleft) =
        IO::Select->select($read_set, undef, undef, 1);

    foreach my $rh (@$rh_set) {
        if ($conntype{$rh->fileno} eq "socket") {
            #print "Got from socket\n";
            my $data;
            my $len = $rh->read($data, 512);
            
            if ($len) {
                $input .= $data;
                
                while (1) {
                    my $pos = index($input, "\n");
                    last if ($pos == -1);
                    &parsecmd($input);
                    $input = substr($input, $pos+1);
                }
            }
            else {
                # socket dropped. stop all builds and restart
                for my $id (keys %builds) {
                    if ($builds{$id}{pid}) {
                        kill 2, $builds{$id}{pid};
                    }
                }                
                goto beginning;
            }
        }
        elsif ($conntype{$rh->fileno} eq "pipe") {
            #print "Got from pipe\n";
            my $len = $rh->read($data, 512);
            if ($len) {
                #print "parent pipe: $data";
                my ($pid, $buildid) = split ' ', $data;
                #print "Waiting for child $pid\n";
                waitpid $pid, WNOHANG;
                $busy = 0;
                $read_set->remove($rh);
                delete $conntype{$rh->fileno};
                delete $builds{$buildid};
                close $rh;

                print "COMPLETED $buildid\n";
                print $sock "COMPLETED $buildid\n";

            }
        }
        else {
            die "Got from other (%d)\n", $rh->fileno;
        }
    }

    if (!$busy) {
        for my $id (sort {$builds{$a}{seqnum} <=> $builds{$b}{seqnum}} keys %builds) {
            &startbuild($id);
            last;
        }
    }
}
unlink $pipe;

#################################################

sub startbuild
{
    my ($id) = @_;

    print "Client starting build $id\n";

    # make mother/child pipe
    my $pipe = new IO::Pipe();

    my $pid = fork;
    if ($pid) {
        # mother
        #print "mother: forked $pid\n";
        $builds{$id}{pid} = $pid;
        $pipe->reader();
        $read_set->add($pipe);
        $conntype{$pipe->fileno} = 'pipe';

        push @children, $pid;
        $busy = 1;
    }
    else {
        $pipe->writer();

        my $logfile = "$cwd/$clientname-$id.log";
        my $log = ">> $logfile 2>&1";
        
        # child
        `svn up -r $builds{$id}{rev} $log`;
        mkdir "build-$$";
        chdir "build-$$";
        my $args = $builds{$id}{confargs};
        $args =~ s|,| |g;
        `../tools/configure $args $log`;
        if ($builds{$id}{mt} eq "mt" and $cores > 1) {
            my $c = $cores + 1;
            `make -j$c $log`;
        }
        else {
            `make $log`;
        }

        print "Uploading $logfile...\n";
        print "curl -v -F upfile=\@$logfile $upload\n";
        `curl -v -F upfile=\@$logfile $upload`;
        print "...done!\n";

        my $zip = $builds{$id}{zip};
        if ($zip ne "nozip") {
            print ">make zip\n";
            my $newzip = "$clientname-$zip";
            rename $zip, $newzip;
            print "Uploading $newzip...\n";
            `curl -F upfile=\@$newzip $upload`;
            print "...done!\n";
        }

        chdir "..";
        `rm -r build-$$`;
        unlink $logfile;

        print "child: $$ $id done\n";
        print $pipe "$$ $id";
        close $pipe;
        exit;
    }
}

sub bogomips
{
    open CPUINFO, "</proc/cpuinfo" or return 0;
    my @lines = grep 'bogomips:', <CPUINFO>;
    close CPUINFO;

    my $bogomips = 0;
    for (@lines) {
        if (/bogomips\s*: (\d+)/) {
            $bogomips += $1;
        }
    }

    return ($bogomips, scalar @lines);
}
    
sub _HELLO
{
    die @_ if ($_[0] ne "ok");
}

sub _COMPLETED
{
}

sub PING
{
    print ">_PING\n";
    print $sock "_PING\n";
}

sub CANCEL
{
    my ($id) = @_;

    if ($builds{$id}{pid}) {
        kill 2, $builds{$id}{pid};
        print "Killed build $id (pid $builds{$id}{pid})\n";
    }

    print $sock "_CANCEL $id\n";
}

sub BUILD
{
    my ($buildparams) = @_;
    my ($id, $confargs, $rev, $zip, $mt) = split(' ', $buildparams);

    if (defined $builds{$id}) {
        print $sock "_BUILD 0\n";
        return;
    }

    $builds{$id}{confargs} = $confargs;
    $builds{$id}{rev} = $rev;
    $builds{$id}{zip} = $zip;
    $builds{$id}{mt} = $mt;
    $builds{$id}{seqnum} = $buildnum++;

    print $sock "_BUILD $id\n";

    print "Queued build $buildparams\n";
}

sub parsecmd
{
    my ($cmdstr)=@_;
    my %functions = ('_HELLO', 1,
                     '_COMPLETED', 1,
                     'BUILD', 1,
                     'PING', 1,
                     'CANCEL', 1);
    
    if($cmdstr =~ /^([_A-Z]*) (.*)/) {
        my $func = $1;
        my $rest = $2;
        chomp $rest;
        print "client: $func $rest\n";

        if (defined $functions{$func}) {
            &$func($rest);
        }
        else {
            print "Unknown command '$func'\n";
        }
    }
    else {
        print "Client didn't recognize '$cmdstr'\n";
    }
}

sub testarchs
{
    %which = (
        "arm", "arm-elf-gcc",
        "sh", "sh-elf-gcc",
        "m68k", "m68k-elf-gcc",
        "mipsel", "mipsel-elf-gcc"
        );

    for (split ',', $archlist) {
        my $p = `which $which{$_}`;
        if (not $p =~ m|^/|) {
            die "You specified arch $_ but don't have $which{$_} in your path!\n";
        }
    }

    my $p = `which curl`;
    if (not $p =~ m|^/|) {
        die "I couldn't find 'curl' in your path.\n";
    }
}
