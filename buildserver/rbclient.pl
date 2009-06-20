#!/usr/bin/perl

#use strict;
use IO::Socket;
use IO::Select;
use IO::File;
use IO::Pipe;
use POSIX 'mkfifo';
use POSIX ":sys_wait_h";

my $clientver = 1;
my $username = "foobar";
my $password = "master";
my $clientname = "laptop-".$$;
my $archlist = "m68k,arm.sh";

my $busy = 0;

my $sock;
while (1) {
    $sock = IO::Socket::INET->new(PeerAddr => 'localhost',
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
my $speed = &bogomips;
my $cpu = `uname -m`;
chomp $cpu;
my $os = `uname -o`;
chomp $os;

print $sock "HELLO $clientver $archlist $auth $clientname $cpu 32 $os $speed\n";

# Mail loop active until ^C pressed
my $done = 0;
#$SIG{INT} = sub { warn "received interrupt\n"; $done = 1; };

while (not $done) {
    my @handles = sort map $_->fileno, $read_set->handles;
    my ($rh_set, $timeleft) =
        IO::Select->select($read_set, undef, undef, 1);

    foreach my $rh (@$rh_set) {
        if ($conntype{$rh->fileno} eq "socket") {
            print "Got from socket\n";
            my $data;
            my $len = $rh->read($data, 512);
            
            if ($len) {
                $input .= $data;
                
                my $pos = index($input, "\n");
                if($pos != -1) {
                    parsecmd($input);
                    $input = substr($input, $pos);
                }
            }
        }
        elsif ($conntype{$rh->fileno} eq "pipe") {
            my $len = $rh->read($data, 512);
            if ($len) {
                print "Got from pipe: $data\n";
                my ($pid, $buildid) = split ' ', $data;
                print "Waiting for child $pid\n";
                waitpid $pid, WNOHANG;
                $busy = 0;
                close $rh;
                $read_set->remove($rh);
                delete $conntype{$rh->fileno};
                delete $builds{$buildid};

                print "COMPLETED $buildid\n";
                print $sock "COMPLETED $buildid\n";

            }
        }
        else {
            die "Got from other (%d)\n", $rh->fileno;
        }
    }

    if (!$busy) {
        for my $id (sort {$a <=> $b} keys %builds) {
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
        $pipe->reader();
        $read_set->add($pipe);
        $conntype{$pipe->fileno} = 'pipe';

        push @children, $pid;
        $busy = 1;
    }
    else {
        $pipe->writer();

        # child
        print ">svn up -r $builds{$id}{rev}\n";
        mkdir "build-$$";
        chdir "build-$$";
        my $args = $builds{$id}{$confargs};
        $args =~ s|,| |g;
        print ">../tools/configure $args\n";
        print ">make\n";
        chdir "..";
        print ">rm -r $build-$$\n";
        `rm -r build-$$`;

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

    return $bogomips;
}
    
sub _HELLO
{
}

sub _COMPLETED
{
}

sub BUILD
{
    my ($id, $confargs, $rev, $zip, $mt) = split(' ', shift @_);

    if (defined $builds{$id}) {
        print SOCKET "_BUILD 0\n";
        return;
    }

    $builds{$id}{confargs} = $confargs;
    $builds{$id}{rev} = $rev;
    $builds{$id}{zip} = $zip;
    $builds{$id}{mt} = $mt;

    print SOCKET "_BUILD $id\n";

    print "Queued build $id $confargs\n";
}

sub parsecmd
{
    my ($cmdstr)=@_;
    
    if($cmdstr =~ /([_A-Z]*) (.*)/) {
        my $func = $1;
        my $rest = $2;
        chomp $rest;
        print "client: $func $rest\n";

        &$func($rest);
    }
    else {
        print "Client didn't recognize '$cmdstr'\n";
    }
}
