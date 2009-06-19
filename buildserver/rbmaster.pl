#!/usr/bin/perl -w
#
# Working example of doing listen/accept of incoming connections,
# and non-blocking read of data on those connections.
# 05-Sep-2002 Ralph Siemsen <ralphs@netwinder.org>

#use strict;
use IO::Socket;
use IO::Select;

# Each active connection gets an entry here, keyed by its filedes.
# Could have used IO::Socket objects as keys, but they hash poorly.
# Any per-connection data can be sotred in this hash-of-hashes.
my %conn;

my %builds;
my @buildids;

sub getbuilds {
    my ($filename)=@_;
    open(F, "<$filename");
    while(<F>) {
        # sdl:nozip:recordersim:Recorder - Simulator:rockboxui:--target=recorder,--ram=2,--type=s
        if($_ =~ /([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)/) {
            my ($arch, $zip, $id, $name, $file, $confopts) =
                ($1, $2, $3, $4, $5, $6);
            $builds{$id}{'arch'}=$arch;
            $builds{$id}{'zip'}=$zip;
            $builds{$id}{'name'}=$name;
            $builds{$id}{'file'}=$file;
            $builds{$id}{'confopts'}=$confopts;

            push @buildids, $id;

         #   printf "$id:%d\n", int(rand(1000));
        }
    }
    close(F);
#    printf ("%d builds read\n", scalar(@buildids));
}


# read the "weight", the score, of builds from a separate file
sub getbuildscore {
    my ($filename)=@_;
    open(F, "<$filename");
    while(<F>) {
        # id:score
        if($_ =~ /([^:]*):(.*)/) {
            my ($id, $score) = ($1, $2);
            $builds{$id}{'score'}=$score;
        }
    }
    close(F);

#    for(sort { $builds{$b}{'score'} <=> $builds{$a}{'score'} }  @buildids) {
#        printf "$_:%d\n", $builds{$_}{'score'};
#    }
}

#
# {$rh}{'cmd'} for building incoming commands
#  {'client'} 
#  {'archs'} 
#  {'cpu'} - string for stats
#  {'bits'} 32 / 64 
#  {'os'}
#  {'bogomips'}
#
my %client;

sub build {
    my ($build, $rh) = @_;
}

sub HELLO {
    my ($rh, $args) = @_;

    my ($version, $auth, $client, $archlist, $cpu, $bits,
        $os, $bogomips) = split(" ", $args);

    $client{$rh}{'client'} = $client;
    $client{$rh}{'archs'} = $archlist;
    $client{$rh}{'cpu'} = $cpu;
    $client{$rh}{'bits'} = $bits;
    $client{$rh}{'os'} = $os;
    $client{$rh}{'bogomips'} = $bogomips;

    # send OK
    $rh->write("_HELLO ok $client\n");
}


sub parsecmd {
    my ($rh, $cmdstr)=@_;
    
    if($cmdstr =~ /([A-Z]*) (.*)/) {
        my $func = $1;
        my $rest = $2;
        chomp $rest;
        print "$func received\n";

        &$func($rh, $rest);
    }
}

my $count;
sub checkbuild {
    if(++$count < 5) {
        return;
    }

    # time to run builds!!!!
    for(sort { $builds{$b}{'score'} <=> $builds{$a}{'score'} }  @buildids) {
        printf "$_:%d\n", $builds{$_}{'score'};
    }
}

# Master socket for receiving new connections
my $server = new IO::Socket::INET(
	LocalHost => "localhost",
	LocalPort => 19999,
	Proto => "tcp",
	Listen => SOMAXCONN,
	Reuse => 1)
or die "socket: $!\n";

getbuilds("builds");

getbuildscore("build-score");

my $debug;

# Add the master socket to select mask
my $read_set = new IO::Select();
$read_set->add($server);
$conn{$server->fileno} = { type => 'master' };

# Mail loop active until ^C pressed
my $done = 0;
$SIG{INT} = sub { warn "received interrupt\n"; $done = 1; };
while(not $done) {
	my @handles = sort map $_->fileno, $read_set->handles;
	warn "waiting on (@handles)\n" if($debug);
	my ($rh_set, $timeleft) =
            IO::Select->select($read_set, undef, undef, 1);

	foreach my $rh (@$rh_set) {
		die "untracked rh" unless exists $conn{$rh->fileno};
		my $type = $conn{$rh->fileno}{type};
		warn "event $rh, fd ", $rh->fileno, ", type $type\n";
		if ($type eq 'master') {
			warn "server accepting\n";
			my $new = $rh->accept or die;
			$read_set->add($new);
			$conn{$new->fileno} = { type => 'http' };
			$new->blocking(0) or die "blocking: $!";
		} else {
			warn "client trying to read\n";
			my $data;
			my $len = $rh->read($data, 512);

			# Note: thereis a bug here.  Since the socket is
			# nonblocking we should read all available data.
			# Otherwise we won't be woken up again.
			if ($data) {
                            warn "okay, read '$data'\n";
                            $client{$rh}{'cmd'} .= $data;
                            my $c = $client{$rh}{'cmd'};
                            
                            my $pos = index($c, "\n");
                            if($pos != -1) {
                                print "GOT: $c\n";
                                parsecmd($rh, $c);
                                $client{$rh}{'cmd'} = substr($c, $pos);
                            }
			}
                        else {
                            warn "failed, removing client\n";
                            delete $conn{$rh->fileno};
                            $read_set->remove($rh);
                            $rh->close;
                            delete $client{$rh};
			}
		}
	}
        checkbuild();
}
warn "exiting.\n";
