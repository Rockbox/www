#!/usr/bin/perl -w
#

use IO::Socket;
use IO::Select;

# Each active connection gets an entry here, keyed by its filedes.
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
            $builds{$id}{'handcount'} = 0; # not handed out to anyone

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
    my ($fileno, $id) = @_;

    my $rh = $client{$fileno}{'socket'};

    my $args = sprintf("%s %s %d %s %s",
                       $id,
                       $builds{$id}{'confopts'},
                       12345,
                       $builds{$id}{'zip'},
                       "n/a");
    
    # tell client to build!
    $rh->write("BUILD $args\n");

    printf "Tell %s to build %s\n",  $client{$fileno}{'client'}, $id;

    # mark this client with what response we expect from it
    $client{$fileno}{'expect'}="_BUILD";
}

sub _BUILD {
    my ($rh, $args) = @_;

    print "got _BUILD back from client\n";
}

sub HELLO {
    my ($rh, $args) = @_;

    my ($version, $archlist, $auth, $cli, $cpu, $bits,
        $os, $bogomips) = split(" ", $args);

    my $fno = $rh->fileno;

    $client{$fno}{'client'} = $cli;
    $client{$fno}{'archs'} = $archlist;
    $client{$fno}{'cpu'} = $cpu;
    $client{$fno}{'bits'} = $bits;
    $client{$fno}{'os'} = $os;
    $client{$fno}{'bogomips'} = $bogomips;
    $client{$fno}{'socket'} = $rh;

    # send OK
    $rh->write("_HELLO ok\n");

    print " $cli at fileno $fno\n";
}

sub COMPLETED {
    my ($rh, $args) = @_;

    my ($id) = split(" ", $args);

    # send OK
    $rh->write("_COMPLETED $id\n");
}


sub parsecmd {
    my ($rh, $cmdstr)=@_;
    
    if($cmdstr =~ /([A-Z_]*) (.*)/) {
        my $func = $1;
        my $rest = $2;
        chomp $rest;
        &$func($rh, $rest);
    }
}

# $a and $b are buildids
sub sortbuilds {
    # 'handcount' is the number of times the build has been handed out
    # to a client. Get the lowest one first.
    my $s = $builds{$a}{'handcount'} <=> $builds{$b}{'handcount'};

    if(!$s) {
        # if the same handcount, take score into account
        $s = $builds{$b}{'score'} <=> $builds{$a}{'score'};
    }
    return $s;
}

# $a and $b are file numbers
sub sortclients {
    return $client{$b}{'bogomips'} <=> $client{$a}{'bogomips'};
}


my $count;
sub checkbuild {
    if(++$count < 5) {
        return;
    }
    $count = 0;

    my @scl; # list of $fileno sorted

    for(sort sortclients keys %client) {
        if(!$client{$_}{'building'}) {
            # only add clients not actually building right now
            push @scl, $_;
        }
    }

    if(!$scl[0]) {
        # none no-building clients around, bail out
        print "No clients available/free to get builds\n";
        return;
    }

    # time to go through the builds and give to clients
    for(sort sortbuilds @buildids) {
        my $cl = pop @scl;

        if(!$cl) {
            # no more clients, get out of loop
            last;
        }

        $client{$cl}{'building'}++;

        build($cl, $_);
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
	#	warn "event $rh, fd ", $rh->fileno, ", type $type\n";
		if ($type eq 'master') {
			warn "server accepting\n";
			my $new = $rh->accept or die;
			$read_set->add($new);
			$conn{$new->fileno} = { type => 'rbclient' };
			$new->blocking(0) or die "blocking: $!";
		} else {
	#		warn "client trying to read\n";
			my $data;
			my $len = $rh->read($data, 512);

			# Note: thereis a bug here.  Since the socket is
			# nonblocking we should read all available data.
			# Otherwise we won't be woken up again.
			if ($data) {
        #                   warn "okay, read '$data'\n";
                            my $fileno = $rh->fileno;
                            $client{$fileno}{'cmd'} .= $data;
                            my $c = $client{$fileno}{'cmd'};
                            
                            my $pos = index($c, "\n");
                            if($pos != -1) {
        #                       print "GOT: $c\n";
                                parsecmd($rh, $c);
                                $client{$fileno}{'cmd'} = substr($c, $pos);
                            }
			}
                        else {
                            warn "failed, removing client\n";
                            delete $client{$rh->fileno};
                            delete $conn{$rh->fileno};
                            $read_set->remove($rh);
                            $rh->close;
			}
		}
	}
        checkbuild();
}
warn "exiting.\n";
