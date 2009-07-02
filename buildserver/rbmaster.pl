#!/usr/bin/perl
#
# This is the server-side implementation according to the concepts and
# protocol posted here:
#
# http://www.rockbox.org/twiki/bin/view/Main/BuildServerRemake
#

# this is the local directory where clients upload logs and zips etc
my $uploadpath="upload";

# this is the local directory where zips and logs are moved to
my $store="data";

# the number of builds handed out to each client
my $buildsperclient = 3;

# the minimum protocol version supported. The protocol version is provided
# by the client
my $minimumversion = 10;

# the name of the server log
my $logfile="logfile";

# if the client is found too old, this is a svn rev we tell the client to
# use to pick an update
my $updaterev = 21609;

use IO::Socket;
use IO::Select;
use DBI;

# secrets.pm is optional and may contain:
#
# The master commander password that must be presented when connecting
# $rb_cmdpasswd = "secret";
#
# Enabling the commander concept
# $rb_cmdenabled = 1;       enables the commander system
#
# The shell script run after each build is completed. The arguments for this
# script is $buildid $client-$user.
# NOTE: this script is called synchronously. Make it run fast.
# $rb_eachcomplete = "scriptname.sh";
#
# The shell script run after each build round is completed. No arguments.
# NOTE: this script is called synchronously. Make it run fast.
# $rb_buildround = "scriptname.sh"
#
# The account details used to access the mysql database.
# $rb_dbuser = 'dbuser';
# $rb_dbpwd = 'dbpwd';
#
eval 'require "secrets.pm"';

# Each active connection gets an entry here, keyed by its filedes.
my %conn;

my %builds;
my @buildids;

# this is $rev while we're in a build round, 0 otherwise
my $buildround;

# queue of builds to do after the current buildround. pop them from the top
# when building, push them to the list when adding
my @buildqueue;

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

sub slog {
    my ($l)=@_;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);

    open(L, ">>$logfile");
    printf L ("%04d%02d%02d-%02d:%02d:%02d $l",
              $year+1900, $mon+1, $mday, $hour, $min, $sec);
    close(L);
}

# return an array with the file number of all fine build clients
sub build_clients {
    my @list;
    for my $cl (keys %client) {
        if($client{$cl}{'fine'}) {
            push @list, $cl;
        }
    }
    return @list;
}

sub kill_build {
    my ($id)=@_;

    my $num;

    # now kill this build on all clients still building it
    for my $cl (&build_clients) {
        # cut out this build from this client
        if($client{$cl}{'builds'}=~ s/-$id-//) {
            my $rh = $client{$cl}{'socket'};

            my $took = time() - $client{$cl}{'btime'}{$id};

            print "> CANCEL $id (on $cl) after $took seconds\n";

            slog sprintf("Cancel: build $id client %s seconds %d\n",
                         $client{$cl}{'client'}, $took);

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
    return $num;
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
    my ($cl, $rev) = @_;

    my $rh = $client{$cl}{'socket'};

    # tell client to build!
    $rh->write("UPDATE $rev\n");
    $client{$cl}{'expect'}="_UPDATE";

    slog sprintf("Update: rev $rev client %s\n",
                 $client{$cl}{'client'});

}


sub build {
    my ($fileno, $id) = @_;

    my $rh = $client{$fileno}{'socket'};
    my $rev = $buildround;
    my $args = sprintf("%s %s %d %s %s %s",
                       $id,
                       $builds{$id}{'confopts'},
                       $rev,
                       $builds{$id}{'zip'},
                       "mt", # TODO: add support for this
                       $builds{$id}{'file'});
    
    # tell client to build!
    $rh->write("BUILD $args\n");
    $client{$fileno}{'expect'}="_BUILD";

    print "Build $args\n";

    slog sprintf("Build: build $id rev $rev client %s\n",
                 $client{$fileno}{'client'});

    # mark this client with what response we expect from it
    $client{$fileno}{'building'}++;

    # remember what this client is building
    $client{$fileno}{'builds'}.= "-$id-";

    # remember when this build started
    $client{$fileno}{'btime'}{$id} = time();

    # count the number of times this build is handed out
    $builds{$id}{'handcount'}++;

    #printf "Build $id handed out %d times\n", $builds{$id}{'handcount'};
}

sub _BUILD {
    my ($rh, $args) = @_;

    $client{$rh->fileno}{'expect'}="";
}

sub _PING {
    my ($rh, $args) = @_;

    $client{$rh->fileno}{'expect'}="";
}

sub _UPDATE {
    my ($rh, $args) = @_;

    $client{$rh->fileno}{'expect'}="";
}

sub _CANCEL {
    my ($rh, $args) = @_;

    $client{$rh->fileno}{'expect'}="";
}

my $commander;
sub HELLO {
    my ($rh, $args) = @_;

    my ($version, $archlist, $auth, $cli, $cpu, $bits,
        $os, $bogomips) = split(" ", $args);

    my $fno = $rh->fileno;

    if(($version eq "commander") &&
       ($archlist eq "$rb_cmdpasswd") &&
       (1 eq "$rb_cmdenabled") &&
       !$commander) {
        $commander++;

        # remove this from the client hash
        delete $client{$fno};

        print "Commander attached at $fno\n";
        slog "Commander attached\n";

        $conn{$fno}{type} = "commander";
    }
    elsif(!$bogomips) {
        # send error
        print "Bad HELLO: $args\n";

        $rh->write("_HELLO error\n");
        $client{$fno}{'bad'}="HELLO failed";
    }
    else {
        my $user;
        if($auth =~ /([^:]*):(.*)/) {
            $user = $1;
        }
        $cli .= "-$user"; # append the user name

        for my $cl (@build_clients) {
            if($client{$cl}{'client'} eq "$cli") {
                print "HELLO dupe name: $cli ($args)\n";
                $rh->write("_HELLO error duplicate name!\n");
                $client{$fno}{'bad'}="duplicate name";
                $client{$fno}{'client'} = "$cli.$$";
                return;
            }
        }

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

        # send OK
        $rh->write("_HELLO ok\n");

        print "Joined: $args\n";

        if($version < $minimumversion) {
            updateclient($fno, $updaterev);
            $client{$fno}{'bad'}="asked to update";
        }
        else {
            $client{$fno}{'fine'} = 1;
            handoutbuilds();
        }
        slog "Joined: client $cli user $user arch $archlist bogomips $bogomips\n";
    }
}

sub COMPLETED {
    my ($rh, $args) = @_;
    my $cli = $client{$rh->fileno}{'client'};

    my ($id) = split(" ", $args);

    print "< COMPLETED $id\n";

    if($builds{$id}{'done'}) {
        # This is a client saying this build is completed although it has
        # already been said to be. Most likely because we killed this build
        # already but the client didn't properly obey!
        slog "Duplicate completion from $cli. $id is already complete\n";
        print "ALERT: this build was already completed!!!\n";
        return;
    }


    # remember when this build started
    my $took = time() - $client{$rh->fileno}{'btime'}{$id};

    # mark this as not building anymore
    $client{$rh->fileno}{'building'}--;

    # cut out this build from this client
    $client{$rh->fileno}{'builds'}=~ s/-$id-//;

    $builds{$id}{'handcount'}--; # one less that builds this
    $builds{$id}{'done'}=1;

    # send OK
    $rh->write("_COMPLETED $id\n");

    # now kill this build on all clients still building it
    my $kills = kill_build($id);

    slog sprintf("Completed: build $id client %s seconds %d kills %d\n",
                 $cli, $took, $kills);

    # log this build in the database
    # (must be done before handoutbuilds() since it will reset $buildround)
    if ($rb_dbuser) {
        &db_submit($buildround, $id, $cli, $took,
                   $client{$rh->fileno}{'bogomips'});
    }

    # if we have builds not yet completed, hand out one
    handoutbuilds();

    my $base=sprintf("$uploadpath/%s-%s", $cli, $id);
                     
    if($builds{$id}{'zip'} eq "zip") {
        # if a zip was included in the build
        rename("$base.zip", "$store/rockbox-$id.zip");
    }
    # now move over the build log
    rename("$base.log", "$store/rockbox-$id.log");

    # now store some data about this build
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);

    open(L, ">$store/rockbox-$id.info");
    printf L ("%04d%02d%02d-%02d:%02d:%02d client %s seconds %d\n",
              $year+1900, $mon+1, $mday, $hour, $min, $sec,
              $cli, $took);
    close(L);

    if($rb_eachcomplete) {
        system("$rb_eachcomplete $id $cli");
    }
}

sub db_submit
{
    my ($revision, $id, $client, $timeused, $bogomips) = @_;
    my $dbpath = 'DBI:mysql:rockbox';
    my $db = DBI->connect($dbpath, $rb_dbuser, $rb_dbpwd);
    my $sth = $db->prepare("INSERT INTO builds (revision,id,client,timeused,bogomips) VALUES (?,?,?,?,?)");
    $sth->execute($revision, $id, $client, $timeused, $bogomips);
    $db->disconnect();
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
    my ($rev) = @_;
    # start a build round
    print "START a new build round for rev $rev\n";
    slog sprintf("New round: %d clients %d builds rev $rev\n",
                 scalar(&build_clients), scalar(@buildids));

    $buildround=$rev;
    $buildstart=time();

    resetbuildround();

    handoutbuilds();
}

my $count;

sub endround {
    # end if a build round

    if(!$buildround) {
        # avoid accidentally doing this twice
        return;
    }

    my $inp = builds_in_progress();
    my $took = time() - $buildstart;
    my $kills;

    # kill all still handed out builds
    for my $id (@buildids) {
        if($builds{$id}{'handcount'}) {
            # find all clients building this and cancel
            $kills += kill_build($id);
            $builds{$id}{'handcount'}=0;
        }
    }
    print "END of a build round, $took seconds, skipped $inp builds\n";
    slog "End of round: skipped $inp seconds $took kill $kills\n";

    resetbuildround();

    if($rb_buildround) {
        system("$rb_buildround");
    }
    $buildround=0;
}

sub checkbuild {
    if(!$buildround) {
        my $q = pop @buildqueue;

        if($q) {
            # if there was an entry in the queue, start the new build
            startround($q);
        }
    }
}

sub checkclients {
    my $check = time() - 10;

    for my $cl (&build_clients) {

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
        return 1;
    }
    
    return 0; # no can build
}

sub client_gone {
    my ($cl) = @_;

    # check which builds this client had going, and count down the handcount
    # on those
    my $b = $client{$cl}{'builds'};

    if($b) {
        my @bip = split("--+", $b);
        for my $id (@bip) {
            # we deduct the handcount since the client building this is gone
            $builds{$id}{'handcount'}--;
        }
    }
}

my $stat;

sub handoutbuilds {
    my @scl; # list of clients $fileno sorted

    if(!$buildround) {
        # don't hand out builds unless we're in a build round
        return;
    }

    for(sort sortclients &build_clients) {
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
        for my $id (sort sortbuilds @buildids) {
            if($builds{$id}{'done'}) {
                $done++;
                next;
            }

            if($client{$cl}{'builds'} =~ /-$id-/) {
                # this client is already building this build, skip it
                next;
            }

            if(client_can_build($cl, $id)) {
                build($cl, $id);
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
    my $bc = scalar(&build_clients);

    # only display this stat if different than last time
    my $thisstat="$und-$inp-$bc";
    if($thisstat ne $stat) {
        print "$und builds not complete, $bc clients. $inp builds in progress\n";
        $stat = $thisstat;
    }

    if(!$inp && $und) {
        # there's no builds in progress because we don't have clients or
        # the clients can't build the builds we have left, and thus we
        # consider this build round complete!
        endround();
    }
}

# Control commands:
#
# BUILD [rev] - start a build immediately, or fail if one is already in
# progress
#
# QUEUE [rev] - queue a build. Do it at once if possible, or add it to get
# done afterwards.
#

sub control {
    my ($cmd, $rh) = @_;
    if($cmd =~ /^BUILD (\d+)/) {
        if(!$buildround) {
            &startround($1);
            $rh->write("OK!\n");
        }
        else {
            $rh->write("BUSY!\n");
        }
    }
    elsif($cmd =~ /^QUEUE (\d+)/) {
        if(!$buildround) {
            &startround($1);
        }
        else {
            push @buildqueue, $1;
        }
        $rh->write("OK!\n");
    }
}

# Master socket for receiving new connections
my $server = new IO::Socket::INET(
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

print "Server starts\n";

slog "Server starts\n";

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
        elsif ($type eq 'commander') {
            my $data;
            my $len = $rh->read($data, 512);

            if ($data) {
                chomp $data;
                control($data, $rh);
            }
            else {
                print "Commander left\n";
                slog "Commander left\n";                
                delete $conn{$rh->fileno};
                $read_set->remove($rh);
                $rh->close;
                $commander=0;
            }
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
            my $cli = $client{$cl}{'client'};

            printf("Client disconnect ($err), removing client $cli on %d\n",
                   $rh->fileno);
            slog "Disconnect: client $cli reason $err\n";
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
