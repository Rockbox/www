#!/usr/bin/perl -w
#
# This is the server-side implementation according to the concepts and
# protocol posted here:
#
# http://www.rockbox.org/twiki/bin/view/Main/BuildServerRemake
#

use IO::Socket;
use IO::Select;

# Each active connection gets an entry here, keyed by its filedes.
my %conn;

my %builds;
my @buildids;

# this is 1 while we're in a build round
my $buildround;

my %client;
#
# {$fileno}{'cmd'} for building incoming commands
#  {'client'} 
#  {'archs'} 
#  {'cpu'} - string for stats
#  {'bits'} 32 / 64 
#  {'os'}
#  {'bogomips'}
#

sub kill_build {
    my ($id)=@_;

    my $num;

    # now kill this build on all clients still building it
    for my $cl (keys %client) {
        # cut out this build from this client
        if($client{$cl}{'builds'}=~ s/ $id//) {
            my $rh = $client{$cl}{'socket'};

            # tell client to build!
            $rh->write("CANCEL $id\n");
            print "KILL $id on $cl\n";
            $client{$cl}{'expect'}="_CANCEL";
            $num++;
        }
    }
    if($num) {
        print "Killed $num remaining $id build!\n";
    }
}

sub builds_in_progress {
    my $c=0;
    # count all builds that are handed out (once or more), but that aren't
    # complete yet
    for my $id (@buildids) {
        if($builds{$id}{'done'}) {
            # for safety, skip the ones that are done already
            next;
        }
        if($builds{$id}{'handcount'}) {
            $c++;
        }
    }
    return $c;
}

sub builds_undone {
    my $c=0;
    # count all builds that aren't marked as done
    for my $id (@buildids) {
        if(!$builds{$id}{'done'}) {
            $c++;
        }
    }
    return $c;
}

sub getbuilds {
    my ($filename)=@_;
    open(F, "<$filename");
    while(<F>) {
        # sdl:nozip:recordersim:Recorder - Simulator:rockboxui:--target=recorder,--ram=2,--type=s
        if($_ =~ /([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):(.*)/) {
            my ($arch, $zip, $id, $name, $file, $confopts) =
                ($1, $2, $3, $4, $5, $6);
            $builds{$id}{'arch'}=$arch;
            $builds{$id}{'zip'}=$zip;
            $builds{$id}{'name'}=$name;
            $builds{$id}{'file'}=$file;
            $builds{$id}{'confopts'}=$confopts;
            $builds{$id}{'handcount'} = 0; # not handed out to anyone
            $builds{$id}{'done'} = 0; # not done

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
}

sub build {
    my ($fileno, $id) = @_;

    my $rh = $client{$fileno}{'socket'};

    my $args = sprintf("%s %s %d %s %s",
                       $id,
                       $builds{$id}{'confopts'},
                       12345,
                       $builds{$id}{'zip'},
                       "n/a"); # TODO: add support for this
    
    # tell client to build!
    $rh->write("BUILD $args\n");

    print "BUILD $args\n";

    printf "Tell %s to build %s\n",  $client{$fileno}{'client'}, $id;

    # mark this client with what response we expect from it
    $client{$fileno}{'building'}++;
    $client{$fileno}{'expect'}="_BUILD";

    # remember what this client is building
    $client{$fileno}{'builds'}.= " $id";

    # count the number of times this build is handed out
    $builds{$id}{'handcount'}++;

    printf "Build $id handed out %d times\n", $builds{$id}{'handcount'};
}

sub _BUILD {
    my ($rh, $args) = @_;

    print "got _BUILD back from client\n";
    $client{$rh->fileno}{'expect'}="";
}

sub _PING {
    my ($rh, $args) = @_;

    print "got _PING back from client\n";
    $client{$rh->fileno}{'expect'}="";
}

sub _CANCEL {
    my ($rh, $args) = @_;

    print "got _CANCEL back from client\n";
    $client{$rh->fileno}{'expect'}="";
}

sub HELLO {
    my ($rh, $args) = @_;

    my ($version, $archlist, $auth, $cli, $cpu, $bits,
        $os, $bogomips) = split(" ", $args);

    my $fno = $rh->fileno;

    $client{$fno}{'client'} = $cli;
    $client{$fno}{'archlist'} = $archlist;
    $client{$fno}{'cpu'} = $cpu;
    $client{$fno}{'bits'} = $bits;
    $client{$fno}{'os'} = $os;
    $client{$fno}{'bogomips'} = $bogomips;
    $client{$fno}{'socket'} = $rh;
    $client{$fno}{'expect'} = "";

    if(!$bogomips) {
        # send error
        $rh->write("_HELLO error\n");
        $client{$fno}{'bad'}="HELLO failed\n";
    }
    else {
        $client{$fno}{'bad'} = 0; # not bad!

        # send OK
        $rh->write("_HELLO ok\n");

        print "HELLO from $cli at fileno $fno at bogomips $bogomips\n";

        handoutbuilds();
    }
}

sub COMPLETED {
    my ($rh, $args) = @_;

    my ($id) = split(" ", $args);

    print "COMPLETED $id received\n";

    # mark this as not building anymore
    $client{$rh->fileno}{'building'}=0;

    # cut out this build from this client
    $client{$rh->fileno}{'builds'}=~ s/ $id//;

    $builds{$id}{'handcount'}--; # one less that builds this
    $builds{$id}{'done'}=1;

    # send OK
    $rh->write("_COMPLETED $id\n");

    # now kill this build on all clients still building it
    kill_build($id);

    # if we have builds not yet completed, hand out one
    handoutbuilds();
}


sub parsecmd {
    my ($rh, $cmdstr)=@_;
    
    if($cmdstr =~ /^([A-Z_]*) (.*)/) {
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

sub startround {
    # start a build round
    print "START a new build round\n";
    $buildround=1;
    handoutbuilds();
}

sub endround {
    # end if a build round
    print "END of a build round\n";

    # TODO: kill all still handed out builds
    # TODO: mark all 'done' to undone for next round
    $buildround=0;
}

my $count;
sub checkbuild {
    if(++$count == 5) {
        startround();
    }
}

sub checkclients {
    my $check = time() - 10;

    for my $cl (keys %client) {
        if($client{$cl}{'expect'} eq "_PING") {
            # if this is already waiting for a ping, we take different
            # precautions and allow for some PING response time
            $check = time() - 13;
            if($client{$cl}{'time'} < $check) {
                # no ping response either, disconnect
            }
            next;
        }

        if($client{$cl}{'time'} < $check) {
            # too old, speak up!
            my $rh = $client{$cl}{'socket'};
            my $exp = $client{$cl}{'expect'};
            if($exp) {
                print "ALERT: waiting for $exp from client!\n";
            }

            $rh->write("PING 111\n");
            $client{$cl}{'expect'}="_PING";
        }
    }
}

sub client_can_build {
    my ($cl, $id)=@_;

    # figure out the arch of this build
    my $arch = $builds{$id}{'arch'};

    # see if this arch is mong the supported archs for this client
    if(index($client{$cl}{'archlist'}, $arch) != -1) {
        # yes it can build
        printf("%s can build %s on arch %s\n",
               $client{$cl}{'client'}, $id, $arch);
        return 1;
    }

#    printf("%s CANNOT build %s on arch %s\n",
#           $client{$cl}{'client'}, $id, $arch);
    
    return 0; # no can build
}

sub client_gone {
    my ($cl) = @_;

    my @bip = split(" ", $client{$cl}{'builds'});
    for my $id (@bip) {
        # we deduct the handcount since the client building this is gone
        $builds{$id}{'handcount'}--;
    }
}

sub handoutbuilds {
    my @scl; # list of clients $fileno sorted

    if(!$buildround) {
        # don't hand out builds unless we're in a build round
        return;
    }


    for(sort sortclients keys %client) {
        if(!$client{$_}{'building'}) {
            # only add clients not actually building right now
            push @scl, $_;
        }
    }

    my $done=0;

    while($scl[0]) {
        my $cl = pop @scl;

        $done =0;
        my $found=0;
        # time to go through the builds and give to clients
        for(sort sortbuilds @buildids) {
            if($builds{$_}{'done'}) {
                #printf "$_ is done now, skip\n";
                $done++;
                next;
            }

            if(client_can_build($cl, $_)) {
                build($cl, $_);
                $found=1;
                last;
            }
        }

        if(!$found) {
            printf("ALERT: No build found suitable for client %s\n",
                   $client{$cl}{'client'});
        }

        if($done >= scalar(@buildids)) {
            endround();
            last;
        }
    }

    my $und = builds_undone();
    my $inp = builds_in_progress();
    print "Still $und builds left to complete with $inp in progress\n";

    if(!$inp && $und) {
        # there's no builds in progress because we don't have clients or
        # the clients can't build the builds we have left, and thus we
        # consider this build round complete!
        endround();
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
my $alldone = 0;
$SIG{INT} = sub { warn "received interrupt\n"; $alldone = 1; };
while(not $alldone) {
    my @handles = sort map $_->fileno, $read_set->handles;
    warn "waiting on (@handles)\n" if($debug);
    my ($rh_set, $timeleft) =
        IO::Select->select($read_set, undef, undef, 1);

    foreach my $rh (@$rh_set) {
        die "untracked rh" unless exists $conn{$rh->fileno};
        my $type = $conn{$rh->fileno}{type};

        if ($type eq 'master') {
            warn "server accepting\n";
            my $new = $rh->accept or die;
            $read_set->add($new);
            $conn{$new->fileno} = { type => 'rbclient' };
            $new->blocking(0) or die "blocking: $!";
        }
        else {
            my $data;
            my $len = $rh->read($data, 512);

            if ($data) {
                my $fileno = $rh->fileno;
                $client{$fileno}{'cmd'} .= $data;

                # timestamp incoming data from client
                $client{$fileno}{'time'} = time();
                my $c = $client{$fileno}{'cmd'};
                            
                my $pos = index($c, "\n");
                if($pos != -1) {
                    parsecmd($rh, $c);
                    $client{$fileno}{'cmd'} = substr($c, $pos+1);
                }
            }
            else {
                $client{$rh->fileno}{'bad'}="connection lost";
            }
        }
    }
    checkbuild();
    checkclients();

    # loop over the clients and close the bad ones
    for my $cl (keys %client) {
        my $rh = $client{$cl}{'socket'};
        my $err = $client{$cl}{'bad'};

        if($err) {
            warn "Client disconnect ($err), removing client\n";
            client_gone($rh->fileno);
            delete $client{$rh->fileno};
            delete $conn{$rh->fileno};
            $read_set->remove($rh);
            $rh->close;
            # do the handout builds calculations again now
            # when one client dropped off
            handoutbuilds();
        }
    }

}
warn "exiting.\n";
