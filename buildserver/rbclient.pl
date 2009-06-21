#!/usr/bin/perl -s

#use strict;
use IO::Socket;
use IO::Select;
use IO::File;
use IO::Pipe;
use File::Basename;
use File::Path;
use POSIX 'strftime';
use POSIX ":sys_wait_h";

my $buildmaster = '192.168.1.10';
my $clientver = 4;
my $upload = "http://$buildmaster/b/upload.pl";
my $cwd = `pwd`;
chomp $cwd;

# read -parameters
my $username = $username;
my $password = $password;
my $clientname = $clientname;
my $archlist = $archlist;

my ($speed, $probecores) = &bogomips;
my $cores = $cores || $probecores;

my $cpu = `uname -m`;
chomp $cpu;
my $os = `uname -o`;
chomp $os;

&readconfig($config) if ($config);

unless ($username and $password and $archlist and $clientname) {
    print "Insufficient parameters. You must specify:\n\n-username, -password, -clientname, -archlist\n\noptional setting: -cores\n\nYou can also specify -config=file where parameters are stored as 'label: value'.";
    exit;
}

&testarchs();

beginning:

print "Starting build client $clientname. $speed bogomips and $cores cores.\n";

my $sock;

while (1) {
    $sock = IO::Socket::INET->new(PeerAddr => $buildmaster,
                                  PeerPort => 19999,
                                  Proto    => 'tcp')
        or sleep 1;

    last if ($sock and $sock->connected);
}

$sock->blocking(0);    

# Add the master socket to select mask
my $read_set = new IO::Select();
$read_set->add($sock);
$conntype{$sock->fileno} = 'socket';

my $auth = "$username:$password";
print "HELLO $clientver $archlist $auth $clientname $cpu 32 $os $speed\n";
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
                print "Server socket disconnected! Cleanup and restart.\n";
                for my $id (keys %builds) {
                    if ($builds{$id}{pid}) {
                        &killchild($id);
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

        my $starttime = time();

        mkdir "build-$$";
        my $logfile = "$cwd/build-$$/$clientname-$id.log";
        my $log = ">> $logfile 2>&1";
        
        open DEST, ">$logfile";
        # to keep all other scripts working, use the same output as buildall.pl:
        print DEST "Build Start Single\n";
        
        printf DEST "Build Date: %s\n", strftime("%Y%m%dT%H%M%SZ", gmtime);
        print DEST "Build Type: $id\n";
        print DEST "Build Dir: $cwd/build-$$\n";
        print DEST "Build Server: $clientname\n";
        close DEST;

        # child
        `svn up -r $builds{$id}{rev} $log`;
        chdir "build-$$";
        my $args = $builds{$id}{confargs};
        $args =~ s|,| |g;
        `../tools/configure $args $log`;
        if ($builds{$id}{mt} eq "mt" and $cores > 1) {
            my $c = $cores + 1;
            `make -k -j$c $log`;
        }
        else {
            `make -k $log`;
        }

        # report
        open DEST, ">>$logfile";
        if (-f $builds{$id}{result}) {
            print DEST "Build Status: Fine\n";
        }
        else {
            print "no '$builds{$id}{result}'\n";
            print DEST "Build Status: Failed\n";
        }
        my $tooktime = time() - $starttime;
        print DEST "Build Time: $tooktime\n";
        close DEST;

        &upload($logfile);

        my $zip = $builds{$id}{zip};
        if ($zip ne "nozip") {
            `make zip $log`;
            
            if (-f "rockbox.zip") {
                my $newzip = "$clientname-$id.zip";
                if (rename "rockbox.zip", $newzip) {
                    &upload($newzip);
                }
            }
            else {
                print "?? no rockbox.zip\n";
            }
        }

        chdir "..";
        rmtree "build-$$";
        unlink $logfile;

        print "child: $$ $id done\n";
        print $pipe "$$ $id";
        close $pipe;
        exit;
    }
}

sub upload
{
    my ($file) = @_;
    print "Uploading $file...\n";
    if (not -f $file) {
        print "$file: no such file\n";
        return;
    }

    print "curl -F upfile=\@$file $upload\n";
    `curl -F upfile=\@$file $upload`;
    print "...done!\n";
}

sub bogomips
{
    open CPUINFO, "</proc/cpuinfo" or return 0;
    my @lines = grep /^bogomips/, <CPUINFO>;
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
    my ($arg) = @_;
#    print ">_PING $arg\n";
    print $sock "_PING $arg\n";
}

sub CANCEL
{
    my ($id) = @_;

    if ($builds{$id}{pid}) {
        &killchild($id);
    }

    print $sock "_CANCEL $id\n";
}

sub BUILD
{
    my ($buildparams) = @_;
    my ($id, $confargs, $rev, $zip, $mt, $result) = split(' ', $buildparams);

    if (defined $builds{$id}) {
        print $sock "_BUILD 0\n";
        return;
    }

    $builds{$id}{confargs} = $confargs;
    $builds{$id}{rev} = $rev;
    $builds{$id}{zip} = $zip;
    $builds{$id}{mt} = $mt;
    $builds{$id}{result} = $result;
    $builds{$id}{seqnum} = $buildnum++;

    print $sock "_BUILD $id\n";

    print "Got build $id\n";
}

sub UPDATE
{
    my ($rev) = @_;
    print "Update to $rev\n";

    `curl -o rbclient.pl "http://svn.rockbox.org/viewvc.cgi/www/buildserver/rbclient.pl?revision=$rev"`;

    print $sock "_UPDATE $rev\n";
    sleep 1;
    exit;
}

sub parsecmd
{
    my ($cmdstr)=@_;
    my %functions = ('_HELLO', 1,
                     '_COMPLETED', 1,
                     'BUILD', 1,
                     'PING', 1,
                     'UPDATE', 1,
                     'CANCEL', 1);
    
    if($cmdstr =~ /^([_A-Z]*) (.*)/) {
        my $func = $1;
        my $rest = $2;
        chomp $rest;
        #print "client: $func $rest\n";

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

sub readconfig
{
    my ($file) = @_;

    if (!open CFG, "<$file") {
        print "$file: $!\n";
        return;
    }
    for (<CFG>) {
        if (/^username:\s*(.*)/) {
            $username = $1;
        }
        elsif (/^password:\s*(.*)/) {
            $password = $1;
        }
        elsif (/^clientname:\s*(.*)/) {
            $clientname = $1;
        }
        elsif (/^archlist:\s*(.*)/) {
            $archlist = $1;
        }
        elsif (/^cores:\s*(.*)/) {
            $cores = $1;
        }
    }
    close CFG;
}

sub killchild
{
    my ($id) = @_;
    my $pid = $builds{$id}{pid};
    kill 9, $pid;
    print "Killed build $id\n";
    waitpid $pid, WNOHANG;

    my $dir = "$cwd/build-$pid";
    if (-d $dir) {
        print "Removing $dir\n";
        rmtree $dir or warn "$dir: $!";
    }

    delete $builds{$id};
}
