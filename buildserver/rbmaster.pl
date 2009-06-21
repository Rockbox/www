#!/usr/bin/perl
#
# This is the server-side implementation according to the concepts and
# protocol posted here:
#
# http://www.rockbox.org/twiki/bin/view/Main/BuildServerRemake
#

# this is the local directory where clients upload logs and zips etc
my $uploadpath="/var/www/b/upload";

# the number of builds handed out to each client
my $buildsperclient = 4;

# the minimum protocol version supported. The protocol version is provided
# by the client
my $minimumversion = 5;

# if the client is found too old, this is a svn rev we tell the client to
# use to pick an update
my $updaterev = 21450;

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

my $started = time();

sub kill_build {
    my ($id)=@_;

    my $num;

    # now kill this build on all clients still building it
    for my $cl (keys %client) {
        # cut out this build from this client
        if($client{$cl}{'builds'}=~ s/ $id//) {
            my $rh = $client{$cl}{'socket'};

            print "> CANCEL $id (on $cl)\n";

            # tell client to build!
            $rh->write("CANCEL $id\n");
            $client{$cl}{'expect'}="_CANCEL";
            $num++;

            my $cli = $client{$cl}{'client'};

            unlink <"$uploadpath/$cli-$id"*>;
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
        $c += $builds{$id}{'handcount'};
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
        }
    }
    close(F);
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

sub updateclient {
    my ($fileno, $rev) = @_;

    my $rh = $client{$fileno}{'socket'};

    # tell client to build!
    $rh->write("UPDATE $rev\n");
    $client{$fileno}{'expect'}="_UPDATE";
}


sub build {
    my ($fileno, $id) = @_;

    my $rh = $client{$fileno}{'socket'};

    my $args = sprintf("%s %s %d %s %s %s",
                       $id,
                       $builds{$id}{'confopts'},
                       21443, # rev
                       $builds{$id}{'zip'},
                       "mt", # TODO: add support for this
                       $builds{$id}{'file'});
    
    # tell client to build!
    $rh->write("BUILD $args\n");
    $client{$fileno}{'expect'}="_BUILD";

    print "> BUILD $args\n";

    #printf "** Tell %s to build %s\n",  $client{$fileno}{'client'}, $id;

    # mark this client with what response we expect from it
    $client{$fileno}{'building'}++;

    # remember what this client is building
    $client{$fileno}{'builds'}.= " $id";

    # count the number of times this build is handed out
    $builds{$id}{'handcount'}++;

    #printf "Build $id handed out %d times\n", $builds{$id}{'handcount'};
}

sub _BUILD {
    my ($rh, $args) = @_;

 #   print "< _BUILD\n";
    $client{$rh->fileno}{'expect'}="";
}

sub _PING {
    my ($rh, $args) = @_;

 #   print "< _PING\n";
    $client{$rh->fileno}{'expect'}="";
}

sub _UPDATE {
    my ($rh, $args) = @_;

 #   print "< _UPDATE\n";
    $client{$rh->fileno}{'expect'}="";
}

sub _CANCEL {
    my ($rh, $args) = @_;

 #   print "< _CANCEL\n";
    $client{$rh->fileno}{'expect'}="";
}

sub HELLO {
    my ($rh, $args) = @_;

    my ($version, $archlist, $auth, $cli, $cpu, $bits,
        $os, $bogomips) = split(" ", $args);

    my $fno = $rh->fileno;

    if(!$bogomips) {
        # send error
        $rh->write("_HELLO error\n");
        $client{$fno}{'bad'}="HELLO failed";
    }
    else {
        $client{$fno}{'client'} = $cli;
        $client{$fno}{'archlist'} = $archlist;
        $client{$fno}{'cpu'} = $cpu;
        $client{$fno}{'bits'} = $bits;
        $client{$fno}{'os'} = $os;
        $client{$fno}{'bogomips'} = $bogomips;
        $client{$fno}{'socket'} = $rh;
        $client{$fno}{'expect'} = ""; # no response expected yet
        $client{$fno}{'builds'} = ""; # none so far
        
        $client{$fno}{'bad'} = 0; # not bad!
        $client{$fno}{'fine'} = 1;

        # send OK
        $rh->write("_HELLO ok\n");

        print "< HELLO $args\n";

        if($version < $minimumversion) {
            updateclient($fno, $updaterev);
            $client{$fno}{'bad'}="asked to update";
        }

        handoutbuilds();
    }
}

sub COMPLETED {
    my ($rh, $args) = @_;

    my ($id) = split(" ", $args);

    print "< COMPLETED $id\n";

    # mark this as not building anymore
    $client{$rh->fileno}{'building'}--;

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

# commands it will accept
my %protocmd = (
    'HELLO' => 1,
    'COMPLETED' => 1,
    '_PING' => 1,
    '_KILL' => 1,
    '_BUILD' => 1,
    '_CANCEL' => 1,
    '_UPDATE' => 1,
    );


sub parsecmd {
    my ($rh, $cmdstr)=@_;
    
    if($cmdstr =~ /^([A-Z_]*) (.*)/) {
        my $func = $1;
        my $rest = $2;
        chomp $rest;
        if($protocmd{$func}) {
            &$func($rh, $rest);
        }
        else {
            print "Unknown input: $cmdstr";
        }
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

sub resetbuildround {
    # mark all done builds as not done, not handed out
    for my $id (@buildids) {
        $builds{$id}{'done'}=0;
        $builds{$id}{'handcount'}=0;
    }
}

sub startround {
    # start a build round
    print "START a new build round\n";
    $buildround=1;

    resetbuildround();

    handoutbuilds();
}

my $count;

sub endround {
    # end if a build round
    print "END of a build round\n";

    # kill all still handed out builds
    for my $id (@buildids) {
        if($builds{$id}{'handcount'}) {
            # find all clients building this and cancel
            kill_build($id);
            $builds{$id}{'handcount'}=0;
        }
    }

    resetbuildround();

    $buildround=0;

    # get to a new build soon
    $started = time();
}

sub checkbuild {
    if(time() > $started + 5) {
        $started += 1000;
        startround();
    }
}

sub checkclients {
    my $check = time() - 10;

    for my $cl (keys %client) {
        if(!$client{$cl}{'fine'}) {
            next;
        }

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

   #         print "> PING (to $cl)\n";
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
        return 1;
    }
    
    return 0; # no can build
}

sub client_gone {
    my ($cl) = @_;

    my $b = $client{$cl}{'builds'};

    if($b) {
        my @bip = split(" ", $b);
        for my $id (@bip) {
            # we deduct the handcount since the client building this is gone
            $builds{$id}{'handcount'}--;
        }
    }
}

sub handoutbuilds {
    my @scl; # list of clients $fileno sorted

    if(!$buildround) {
        # don't hand out builds unless we're in a build round
        return;
    }

    for(sort sortclients keys %client) {
        if($client{$_}{'building'} < $buildsperclient) {
            # only add clients with room left for more builds
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

            if($client{$fileno}{'builds'} =~ / $id/) {
                # this client is already building this build, skip it
                next;
            }

            if(client_can_build($cl, $_)) {
                build($cl, $_);
                $found=1;
                last;
            }
        }

        if(!$found && !$client{$cl}{'building'}) {
            printf("ALERT: No build found suitable for '%s' at $cl\n",
                   $client{$cl}{'client'});
        }

        if($done >= scalar(@buildids)) {
            endround();
            last;
        }
    }

    my $und = builds_undone();
    my $inp = builds_in_progress();
    printf(" $und builds not complete, %d clients. $inp builds in progress\n",
           scalar(keys %client));

    if(!$inp && $und) {
        # there's no builds in progress because we don't have clients or
        # the clients can't build the builds we have left, and thus we
        # consider this build round complete!
        endround();
    }
}

# Master socket for receiving new connections
my $server = new IO::Socket::INET(
	#LocalHost => "localhost",
	LocalPort => 19999,
	Proto => "tcp",
	Listen => 5,
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

    # loop over the clients and close the bad ones
    foreach my $rh (@$rh_set) {

        my $type = $conn{$rh->fileno}{type};
        if ($type eq 'master') {
            next;
        }

        my $cl = $rh->fileno;

        my $err = $client{$cl}{'bad'};
        if($err) {
            printf("Client disconnect ($err), removing client on %d\n",
                   $rh->fileno);
            client_gone($cl);
            delete $client{$cl};
            delete $conn{$cl};
            $read_set->remove($rh);
            $rh->close;
            # do the handout builds calculations again now
            # when one client dropped off
        }
    }

    checkbuild();
    checkclients();

    handoutbuilds(); # see if there's more builds to hand out
}
warn "exiting.\n";
