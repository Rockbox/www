#!/usr/bin/perl
#
# This is the server-side implementation according to the concepts and
# protocol posted here:
#
# http://www.rockbox.org/twiki/bin/view/Main/BuildServerRemake
#

# is this a test run or live?
my $test = 0;

# this is the local directory where clients upload logs and zips etc
my $uploadpath="upload";

# this is the local directory where zips and logs are moved to
my $store="data";

# the name of the server log
my $logfile="logfile";

if ($test) {
    $uploadpath="upload_test";
    $store="data_test";
    $logfile="logfile_test";
}

# the minimum protocol version supported. The protocol version is provided
# by the client
my $minimumversion = 31;

# if the client is found too old, this is a svn rev we tell the client to
# use to pick an update
my $updaterev = 22109;


use IO::Socket;
use IO::Select;
use File::Path;
use DBI;
use Time::HiRes qw(gettimeofday tv_interval);
use POSIX 'strftime';

require 'rbmaster.pm';

# Each active connection gets an entry here, keyed by its filedes.
my %conn;

# this is $rev while we're in a build round, 0 otherwise
my $buildround;

# revision to build after the current buildround.
# if several build requests are recieved during a round, we only keep the last
my $nextround;

my %client;

#
# {$fileno}{'cmd'} for building incoming commands
#  {'client'} 
#  {'archs'} 
#  {'cpu'} - string for stats
#  {'bits'} 32 / 64 
#  {'os'}
#

my $started = time();
my $wastedtime = 0; # sum of time spent by clients on cancelled builds

sub slog {
    if (open(L, ">>$logfile")) {
        print L strftime("%F %T ", localtime()), $_[0], "\n";
        close(L);
    }
}

sub dlog {
    if (open(L, ">>debuglog")) {
        print L strftime("%F %T ", localtime()), $_[0], "\n";
        close(L);
    }
}

sub command {
    my ($socket, $string) = @_;
    my $cl = $socket->fileno;
    print $socket "$string\n";
    $client{$cl}{'time'} = time();
}

sub privmessage {
    my ($cl, $string) = @_;

    my $socket = $client{$cl}{'socket'};
    print $socket "MESSAGE $string\n";
    $client{$cl}{'time'} = time();
    $client{$cl}{'expect'} = '_MESSAGE';
}

sub message {
    my ($string) = @_;

    slog "Server message: $string";
    for my $cl (&build_clients) {
        &privmessage($cl, $string);
    }
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
        # remove this build from this client
        if (defined $client{$cl}{queue}{$id} or
            defined $client{$cl}{btime}{$id})
        {
            delete $client{$cl}{queue}{$id};

            # if client started it already, cancel it!
            if (defined $client{$cl}{btime}{$id}) {
                my $rh = $client{$cl}{'socket'};

                my $took = tv_interval($client{$cl}{btime}{$id});

                slog sprintf("Cancel: build $id client %s seconds %d",
                             $client{$cl}{'client'}, $took);

                $wastedtime += $took;
                
                # tell client to cancel!
                command $rh, "CANCEL $id";
                $client{$cl}{'expect'}="_CANCEL";
                $num++;
                
                my $cli = $client{$cl}{'client'};
                
                unlink <"$uploadpath/$cli-$id"*>;
                delete $client{$cl}{btime}{$id};
            }
            else {
                slog "Remove: build $id client $client{$cl}{client}";
            }
        }
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

sub readblockfile {
    if ($lastblockread + 600 < time()) {
        system("svn update --non-interactive -q blockedclients");

        if (open B, "<blockedclients") {
            for my $line (<B>) {
                next if ($line =~ /^#/);
                chomp $line;
                my @a = split ":", $line;
                $blocked{$a[0]} = $a[1];
            }
            close B;

            for my $cl (&build_clients) {
                my $cname = \$clients{$cl}{'client'};
                my $cblocked = \$clients{$cl}{'blocked'};
                if (defined $blocked{$$cname}) {
                    if (not $$cblocked) {
                        slog "Adding client block for $$name. Reason: $blocked{$$name}.";
                    }
                    $$cblocked = 1;
                }
                else {
                    if ($$cblocked) {
                        slog "Removing client block for $$cname";
                    }
                    $$cblocked = 0;
                }
            }
        }
        $lastblockread = time();
    }
}

sub updateclient {
    my ($cl, $rev) = @_;

    my $rh = $client{$cl}{'socket'};

    # tell client to update
    command $rh, "UPDATE $rev";
    $client{$cl}{'expect'}="_UPDATE";
    $client{$cl}{'bad'}="asked to update";

    slog sprintf("Update: rev $rev client %s",
                 $client{$cl}{'client'});

}


sub build {
    my ($fileno, $id) = @_;

    my $rh = $client{$fileno}{'socket'};
    my $cli = $client{$fileno}{'client'};
    my $rev = $buildround;
    my $args = sprintf("%s %s %d %s %s %s",
                       $id,
                       $builds{$id}{'confopts'},
                       $rev,
                       $builds{$id}{'zip'},
                       "mt", # TODO: add support for this
                       $builds{$id}{'file'});

    # tell client to build!
    if ($test) {
        my $ulsize = $builds{$id}{ulsize};
        command $rh, "BUILD $args $ulsize";
    }
    else {
        command $rh, "BUILD $args";
    }
    $client{$fileno}{'expect'}="_BUILD";

    slog "Build: build $id rev $rev client $cli";

    # mark this client with what response we expect from it
    $client{$fileno}{'building'}++;

    # remember when this build started
    $client{$fileno}{'btime'}{$id} = [gettimeofday];

    # count the number of times this build is handed out
    $builds{$id}{'handcount'}++;
    $builds{$id}{'clients'}{$fileno} = 1;

    if (!$test) {
        $setlastrev_sth->execute($cli, $buildround, $buildround);
        $buildclients{$cli} = 1;
    }
}

sub _BUILD {
    my ($rh, $args) = @_;

    $client{$rh->fileno}{'expect'}="";
}

sub _MESSAGE {
    my ($rh, $args) = @_;
    $client{$rh->fileno}{'expect'}="";
}

sub _PING {
    my ($rh, $args) = @_;

    $client{$rh->fileno}{'expect'}="";
    my $t = tv_interval($client{$rh->fileno}{'ping'});
    if ($t > 2) {
        slog "Slow _PING from $client{$rh->fileno}{client} ($t ms)";
    }
}

sub _UPDATE {
    my ($rh, $args) = @_;

    $client{$rh->fileno}{'expect'}="";
}

sub _CANCEL {
    my ($rh, $args) = @_;

    $client{$rh->fileno}{'expect'}="";
    $client{$rh->fileno}{'building'}--;
}

my $commander;
sub HELLO {
    my ($rh, $args) = @_;

    my ($version, $archlist, $auth, $cli, $cpu, $bits, $os) = split(" ", $args);

    my $fno = $rh->fileno;

    if(($version eq "commander") &&
       ($archlist eq "$rb_cmdpasswd") &&
       (1 eq "$rb_cmdenabled") &&
       !$commander) {
        $commander++;

        slog "Commander attached";
        command $rh, "Hello commander";

        $conn{$fno}{type} = "commander";
    }
    elsif($os eq "") {
        # send error
        slog "Bad HELLO: $args";

        command $rh, "_HELLO error";
        $client{$fno}{'bad'}="HELLO failed";
    }
    else {
        my $user;
        if($auth =~ /([^:]*):(.*)/) {
            $user = $1;
        }
        $cli .= "-$user"; # append the user name

        for my $cl (&build_clients) {
            if($client{$cl}{'client'} eq "$cli") {
                slog "HELLO dupe name: $cli ($args)";
                command $rh, "_HELLO error duplicate name!";
                $client{$fno}{'bad'}="duplicate name";
                $client{$fno}{'client'} = "$cli.$$";
                return;
            }
        }

        $client{$fno}{'client'} = $cli;
        for (split(/,/, $archlist)) {
            $client{$fno}{'archlist'}{$_} = 1;
        }
        $client{$fno}{'cpu'} = $cpu;
        $client{$fno}{'bits'} = $bits;
        $client{$fno}{'os'} = $os;
        $client{$fno}{'expect'} = ""; # no response expected yet
        $client{$fno}{'builds'} = ""; # none so far
        $client{$fno}{'bad'} = 0; # not bad!
        $client{$fno}{'blocked'} = $blocked{$cli};

        if($version < $minimumversion) {
            updateclient($fno, $updaterev);
            return;
        }

        my ($speed, $ulspeed) = getspeed($cli);

        # send OK
        if ($test) {
            command $rh, "_HELLO ok $speed $ulspeed";
        }
        else {
            command $rh, "_HELLO ok";
        }

        $client{$fno}{avgspeed} = $speed;
        $client{$fno}{speed} = $speed; 
        $client{$fno}{ulspeed} = $ulspeed; 

        if ($client{$fno}{blocked}) {
            slog "Blocked: client $cli blocked due to: $client{$fno}{blocked}";
            privmessage $fno, sprintf  "Hello $cli. Your build client has been temporarily blocked by the administrators due to: $client{$fno}{blocked}. Please go to #rockbox to enable your client again.";
            return;
        }
        else {
            slog "Joined: client $cli arch $archlist speed $speed";
            privmessage $fno, sprintf  "Welcome $cli. Your average speed is $speed points/sec. Avg upload speed is %d KB/s.", $ulspeed / 1024;
        }
        
        $client{$fno}{'fine'} = 1;

        if ($buildround) {
            start_next_build($fno);
        }
    }
}

sub UPLOADING {
    my ($rh, $id) = @_;
    my $cl = $rh->fileno;
    $builds{$id}{uploading} = 1;
    command $rh, "_UPLOADING";
    
    $client{$cl}{took}{$id} = tv_interval($client{$cl}{btime}{$id});

    # how is he doing?
    my $cli = $client{$cl}{'client'};
    my $rs;
    $client{$cl}{roundscore} += $builds{$id}{score};
    $client{$cl}{roundtime} += $client{$cl}{took}{$id};
    $client{$cl}{roundspeed} = int($client{$cl}{roundscore} / $client{$cl}{roundtime});

    if ($client{$cl}{avgspeed}) {
        $client{$cl}{relativespeed} = int($client{$cl}{speed} * 100 / $client{$cl}{avgspeed});
        $rs = $client{$cl}{relativespeed};
        #$client{$cl}{avgspeed} = $rs;
    }

    if (!$rs or $rs > 120 or $rs < 90) {
        # speed is different from what we used in calculations.
        # redo calculations.
        if (!$rs) {
            slog "$cli has speed $client{$cl}{roundspeed}";
        }
        else {
            dlog sprintf "$cli is running at $rs%% (speed %d)", $client{$cl}{roundspeed};
        }
        # reallocate for unexpectedly slow clients, not for fast
        #if (!$rs or $rs < 80) {
        #    bestfit_builds(0);
        #}
        #estimate_eta();
        #return;
    }
    #bestfit_builds(0);
}

sub GIMMEMORE {
    my ($rh, $args) = @_;

    command $rh, "_GIMMEMORE";

    &start_next_build($rh->fileno);
}

sub COMPLETED {
    my ($rh, $args) = @_;
    my $cl = $rh->fileno;
    my $cli = $client{$cl}{'client'};

    my ($id, $took, $ultime, $ulsize) = split(" ", $args);

    # ACK command
    command $rh, "_COMPLETED $id";

    if($builds{$id}{'done'}) {
        # This is a client saying this build is completed although it has
        # already been said to be. Most likely because we killed this build
        # already but the client didn't properly obey!
        slog "Duplicate $id completion from $cli";
        return;
    }

    if (!$buildround) {
        # round has ended, but someone wasn't killed properly
        # just ignore it
        slog "$cli completed $id after round end";
        return;
    }

    # remove this build from this client
    delete $client{$cl}{queue}{$id};
    delete $client{$cl}{btime}{$id};

    # mark this client as not building anymore
    $client{$cl}{'building'}--;

    my $uplink = 0;
    if ($ulsize and $ultime) {
        $uplink = int($ulsize / $ultime / 1024);
    }

    $took = $client{$cl}{took}{$id};

    my $speed = $builds{$id}{score} / $took;

    my $msg = &check_log(sprintf("$uploadpath/%s-%s.log", $cli, $id));
    if ($msg) {
        slog "Fatal build error: $msg. Disabling client.";
        privmessage $cl, "Fatal build error: $msg. You have been temporarily disabled.";
        $client{$cl}{'blocked'} = $msg;
        return;
    }

    # mark build completed
    $builds{$id}{'handcount'}--; # one less that builds this
    $builds{$id}{'done'}=1;
    $builds{$id}{'uploading'}=0;

    my $left = 0;
    my @lefts;
    for my $b (@buildids) {
        if (!$builds{$b}{done}) {
            $left++;
            my $cl = (keys %{$builds{$b}{clients}})[0];
            my $spent = tv_interval($client{$cl}{btime}{$b}) * $client{$cl}{speed} if ($client{$cl}{speed});
            push @lefts, $b;
        }
    }

    my $timeused = time() - $buildstart;
    slog sprintf "Completed: build $id client $cli seconds %.1f uplink $uplink speed %d time $timeused left $left", $took, $speed;

    if ($left and $left <= 10) {
        slog sprintf "$left builds remaining: %s", join(", ", @lefts);
    }

    # now kill this build on all clients still building it
    my $kills = kill_build($id);

    if (!$test) {
        # log this build in the database
        &db_submit($buildround, $id, $cli, $took, $ultime, $ulsize);

        my $base=sprintf("$uploadpath/%s-%s", $cli, $id);
                     
        if($builds{$id}{'zip'} eq "zip") {
            # if a zip was included in the build
            rename("$base.zip", "$store/rockbox-$id.zip");
        }
        # now move over the build log
        rename("$base.log", "$store/$buildround-$id.log");

        if ($rb_eachcomplete) {
            my $start = time();
            system("$rb_eachcomplete $id $cli $buildround");
            my $took = time() - $start;
            if ($took > 1) {
                slog "rb_eachcomplete took $took seconds";
            }
        }
    }

    if ($ulsize and $client{$cl}{ulspeed}) {
        my $ulspeed = $ulsize / $ultime;
        my $rs = int(($ulspeed * 100 / $client{$cl}{ulspeed}) + 0.5);
        if ($rs > 120 or $rs < 80) {
            dlog "$cli uploads at $rs% speed";
        }
    }

    # are we finished?
    my $finished = 1;
    for my $b (@buildids) {
        if (not $builds{$b}{done}) {
            $finished = 0;
            last;
        }
    }
    if ($finished) {
        &endround();
    }
}

sub check_log
{
    my ($file) = @_;
    if (open F, "<$file") {
        my @log = <F>;
        close F;
        if (grep /No space left on device/, @log) {
            return "Out of disk space";
        }
        if (not grep /^Build Status/, @log) {
            return "Incomplete log file";
        }
        if (grep /^Segmentation fault/, @log) {
            return "Compiler crashed";
        }

        if (grep /gcc: not found/, @log) {
            return "Compiler not found";
        }

        return "";
    }
    else {
        return "Missing log file";
    }
}

sub db_submit
{
    return unless ($rb_dbuser and $rb_dbpwd);

    my ($revision, $id, $client, $timeused, $ultime, $ulsize) = @_;
    if ($client) {
        $submit_update_sth->execute($client, $timeused, $ultime, $ulsize, $revision, $id) or
            warn "DBI: Can't execute statement: ". $submit_update_sth->errstr;
    }
    else {
        $submit_new_sth->execute($revision, $id) or
            warn "DBI: Can't execute statement: ". $submit_new_sth->errstr;
    }
}

# commands it will accept
my %protocmd = (
    'HELLO' => 1,
    'COMPLETED' => 1,
    'UPLOADING' => 1,
    'GIMMEMORE' => 1,
    '_PING' => 1,
    '_KILL' => 1,
    '_BUILD' => 1,
    '_CANCEL' => 1,
    '_UPDATE' => 1,
    '_MESSAGE' => 1,
    );


sub parsecmd {
    my ($rh, $cmdstr)=@_;
    
    if($cmdstr =~ /^([A-Z_]*) *(.*)/) {
        my $func = $1;
        my $rest = $2;
        chomp $rest;
        if($protocmd{$func}) {
            &$func($rh, $rest);
        }
        else {
            chomp $cmdstr;
            slog "Unknown input: $cmdstr";
        }
    }
}

# $a and $b are buildids
sub fastclient {
    # done builds are, naturally, last
    my $s = $builds{$b}{'done'} <=> $builds{$a}{'done'};

    if (!$s) {
        # delay handing out builds that are being uploaded right now
        $s = $builds{$b}{'uploading'} <=> $builds{$a}{'uploading'};
    }

    if (!$s) {
        # 'handcount' is the number of times the build has been handed out
        # to a client. Get the lowest one first.
        $s = $builds{$b}{'handcount'} <=> $builds{$a}{'handcount'};
    }

    if (!$s) {
        # hand out zip builds before nozip
        $s = $builds{$a}{'zip'} cmp $builds{$b}{'zip'};
    }

    if(!$s) {
        # if the same handcount, take score into account
        $s = $builds{$a}{'score'} <=> $builds{$b}{'score'};
    }
    return $s;
}

# $a and $b are buildids
sub slowclient {
    # done builds are, naturally, last
    my $s = $builds{$b}{'done'} <=> $builds{$a}{'done'};

    if (!$s) {
        # delay handing out builds that are being uploaded right now
        $s = $builds{$b}{'uploading'} <=> $builds{$a}{'uploading'};
    }

    if (!$s) {
        # 'handcount' is the number of times the build has been handed out
        # to a client. Get the lowest one first.
        $s = $builds{$b}{'handcount'} <=> $builds{$a}{'handcount'};
    }

    if(!$s) {
        # if the same handcount, take score into account
        $s = $builds{$b}{'score'} <=> $builds{$a}{'score'};
    }
    return $s;
}

# $a and $b are file numbers
sub sortclients {
    return $client{$b}{'speed'} <=> $client{$a}{'speed'};
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

    &getbuilds();

    # no zips during testing
    if ($test) {
        for my $id (@buildids) {
            $builds{$id}{zip} = 'nozip';
        }
    }

    my $num_clients = scalar &build_clients;
    my $num_builds = scalar @buildids;

    slog "New round: $num_clients clients $num_builds builds rev $rev";

    message sprintf "New build round started. Revision $rev, $num_builds builds, $num_clients clients.";

    $buildround=$rev;
    $buildstart=time();
    $wastedtime = 0;
    $phase = 1;
    $countdown = 0;

    resetbuildround();

    if (!$test) {

        # fill db with builds to be done
        for my $id (@buildids) {
            &db_submit($buildround, $id);
        }

        # run housekeeping script
        if ($rb_roundstart) {
            my $start = time();
            system("$rb_roundstart $buildround");
            my $took = time() - $start;
            if ($took > 1) {
                slog "rb_roundstart took $took seconds";
            }
        }
    }
    %buildclients = ();

    &bestfit_builds(1);
}

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
    slog "End of round $buildround: skipped $inp seconds $took wasted $wastedtime";

    message sprintf "Build round completed after $took seconds.";

    resetbuildround();

    # clear upload dir
    rmtree( $uploadpath, {keep_root => 1} );

    if(!$test and $rb_roundend) {
        my $start = time();
        system("$rb_roundend $buildround");
        my $rbtook = time() - $start;
        if ($rbtook > 1) {
            slog "rb_roundend took $rbtook seconds";
        }

        my $rounds_sth = $db->prepare("INSERT INTO rounds (revision, took, clients) VALUES (?,?,?) ON DUPLICATE KEY UPDATE took=?,clients=?") or 
            slog "DBI: Can't prepare statement: ". $db->errstr;
        $rounds_sth->execute($buildround,
                             $took, scalar %buildclients,
                             $took, scalar %buildclients);
    }
    $buildround=0;

    if ($nextround) {
        &startround($nextround);
        $nextround = 0;
    }
}

sub checkclients {
    my $check = time() - 10;

    for my $cl (&build_clients) {

        if($client{$cl}{'expect'} eq "_PING") {
            # if this is already waiting for a ping, we take different
            # precautions and allow for some PING response time
            my $pcheck = time() - 30;
            if($client{$cl}{'time'} < $pcheck) {
                my $t = time() - $client{$cl}{'time'};
                # no ping response either, disconnect
                $client{$cl}{'bad'}="ping timeout (${t}s)";
            }
            next;
        }

        if($client{$cl}{'time'} < $check) {
            # too old, speak up!
            my $rh = $client{$cl}{'socket'};
            my $exp = $client{$cl}{'expect'};
            my $t = time() - $client{$cl}{'time'};
            if($exp) {
                slog "Alert: Waiting ${t}s for $exp from client $client{$cl}{client}!";
            }
            command $rh, "PING 111";
            $client{$cl}{'ping'}=[gettimeofday];
            $client{$cl}{'expect'}="_PING";
        }
    }
}

sub client_can_build {
    my ($cl, $id)=@_;

    # figure out the arch of this build
    my $arch = $builds{$id}{'arch'};

    # see if this arch is among the supported archs for this client
    if(defined $client{$cl}{'archlist'}{$arch}) {
        # yes it can build
        return 1;
    }
    
    return 0; # no cannot build
}

sub client_gone {
    my ($cl) = @_;

    # check which builds this client had queued, and free them up
    for my $id (keys %{$client{$cl}{queue}}) {
        $builds{$id}{'assigned'} = 0;
        slog "$client{$cl}{client} abandoned build $id";
        $abandoned_builds += 1;
    }

    # check which builds this client had started, and decrease handcount
    for my $id (keys %{$client{$cl}{btime}}) {
        $builds{$id}{handcount}--;
        delete $builds{$id}{'clients'}{$cl};
    }

    # are any clients left?
    if ($buildround and (scalar &build_clients) == 0) {
        slog "Ending round due to lack of clients";
        $buildround = 0;
    }
}

sub smallbuilds
{
    return sort {$builds{$a}{score} <=> $builds{$b}{score}} @buildids;
}

sub bigsort
{
    # done builds are, obviously, last
    my $s = $builds{$a}{'done'} <=> $builds{$b}{'done'};

    if (!$s) {
        # delay handing out builds that are being uploaded right now
        $s = $builds{$a}{'uploading'} <=> $builds{$b}{'uploading'};
    }
    
    if (!$s) {
        # 'handcount' is the number of times the build has been handed out
        # to a client. Get the lowest one first.
        $s = $builds{$a}{'handcount'} <=> $builds{$b}{'handcount'};
    }

    if (!$s) {
        # do zip builds before non-zip builds
        my $s = $builds{$a}{'zip'} cmp $builds{$b}{'zip'};
    }

    if (!$s) {
        # do heavy builds before light builds
        $s = $builds{$b}{score} <=> $builds{$a}{score};
    }

    return $s;
}

sub bigbuilds
{
    return sort bigsort @buildids;
}

sub client_eta($)
{
    my ($c) = @_;

    for my $b (keys %{$client{$c}{queue}}) {
        return 0 if ($builds{$b}{uploading});
        if ($client{$c}{btime}{$b} and $client{$c}{speed}) {
            my $expected = $builds{$b}{score} / $client{$c}{speed};
            my $spent = tv_interval($client{$c}{btime}{$b});
            if ($spent > $expected) {
                return 0;
            }
            return ($expected - $spent, $b);
        }
    }
    return 0;
}

my $firsttime = 0;
sub bestfit_builds
{
    my ($start_builds) = @_;

    my %deduct;
    my %todo;
    my $totaldeduct;

    dlog "-----------";

    # calculate total work to be done
    my $totwork = 0;
    for my $b (@buildids) {
        if (!$builds{$b}{done} and !$builds{$b}{uploading}) {
            $totwork += $builds{$b}{score};
        }
    }

    my $totspeed = 0;
    for (&build_clients) {
        $totspeed += $client{$_}{speed};
    }
    slog sprintf "Total work: %d points", $totwork;
    slog sprintf "Total speed: %d points/sec (%d clients)", $totspeed, scalar &build_clients;

    my $idealtime = int(($totwork / $totspeed) + 0.5);
    slog "Ideal time: $idealtime seconds";

    my $margin = 5;

  tryagain:
    my $totleft = 0;
    my $bcount = 0;

    # remove assignments
    for my $b (@buildids) {
        $builds{$b}{assigned} = 0;
    }

    my @debug = ();
    my $realtime = int($totwork / $totspeed + 0.5) + $margin;
    my $diff = 0;
    if ($firsttime) {
        $diff = $realtime - $firsttime - (time - $buildstart);
    }
    slog sprintf "Realistic time with $margin margin: $realtime seconds (%+d)", $diff;
    dlog "----- margin $margin --- realtime $realtime --------";
    
    for my $c (sort {$client{$a}{speed} <=> $client{$b}{speed}} &build_clients)
    {
        $client{$c}{queue} = ();

        my $speed = $client{$c}{speed};
        my $maxtime = $realtime;
        my $timeused = 0;
        my $points = 0;

        my $sort_order;
        if ($speed) {
            # we know how fast the client usually is.
            # give it as much work as it can do
            $sort_order = \&bigbuilds;
        }
        else {
            # if we don't know how fast the client is,
            # give it something light and see how fast it is
            $sort_order = \&smallbuilds;
            $maxtime = 99999;
        }

        my $lastultime = 0;
        my $totultime = 0;
        my $ulspeed = $client{$c}{ulspeed} || 50000; # assume 50 KB/s uplink

        for my $b (&$sort_order)
        {
            next if ($builds{$b}{assigned});

            my $buildtime = 0;
            if ($speed) {
                $buildtime = $builds{$b}{score} / $speed;
            }

            my $ultime = $builds{$b}{ulsize} / $ulspeed;

            if (client_can_build($c, $b) and
                ($timeused + $buildtime + $ultime - $lastultime < $maxtime))
            {
                $client{$c}{queue}{$b} = $buildtime;
                $timeused += $buildtime + $ultime - $lastultime;
                $points += $builds{$b}{score};
                $builds{$b}{assigned} = 1;
                
                $totultime += $ultime - $lastultime;

                #dlog "$client{$c}{client} got $b ($buildtime + $ultime - $lastultime)";

                $lastultime = $ultime;

                $bcount++;

                # speed-less clients only do one build
                last if (!$speed);
            }
        }
        $totleft += int($maxtime - $timeused);

        my @blist;
        my $bcount = 0;
        for my $b (sort bigsort keys %{$client{$c}{queue}}) {
            push @blist, "$b:$builds{$b}{score}:$builds{$b}{ulsize}";
            $bcount ++;
        }
        my $buildlist = join ", ", @blist;

        push @debug, sprintf "%-24s (%3d KB/s) does $bcount/%d points %.1f sec $buildlist", $client{$c}{client}, $ulspeed / 1024, $points, $timeused;
    }

    # any unassigned builds?
    for my $b (@buildids) {
        if (!$builds{$b}{assigned}) {
            # increase the margin and try again
            $margin += 5;
            dlog "*** $b unassigned, trying again";
            #sleep 1;
            goto tryagain;
        }
    }

    for (@debug) {
        dlog $_;
    }

    $firsttime = $realtime if (!$endtime);

    dlog "$bcount builds in $realtime seconds. $totleft seconds unused";

    if ($start_builds) {
        # start all clients who aren't currently running
        for my $c (sort {$client{$a}{speed} <=> $client{$b}{speed}} &build_clients) {
            if (!scalar keys %{$client{$c}{btime}}) {
                &start_next_build($c);
            }
        }
    }
}

sub start_next_build($)
{
    my ($cl) = @_;

    return if (!$buildround);

    my $cli = $client{$cl}{client};

    # start next in queue
    for my $id (sort bigsort keys %{$client{$cl}{queue}})
    {
        if (!$builds{$id}{done} and !$builds{$id}{uploading})
        {
            &build($cl, $id);
            return;
        }
    }

    # queue is empty. how can I help?

    # any abandoned builds I can do?
    if ($abandoned_builds)
    {
        for my $id (&bigbuilds) {
            if (client_can_build($cl, $id) and !$builds{$id}{assigned}) {
                $client{$cl}{queue}{$id} = 1;
                $builds{$id}{assigned} = 1;
                $abandoned_builds -= 1;
                dlog "$cli does abandoned $id";
                &build($cl, $id);
                return;
            }
        }
    }
    
    if (1) {
        # help with other builds, speculatively
        for my $id (&bigbuilds) {
            next if (!client_can_build($cl, $id));
            if (!$builds{$id}{done}) {
                if ($builds{$id}{handcount} == 0) {
                    dlog "$cli does unstarted $id";
                }
                else {
                    dlog "$cli does unfinished $id ($builds{$id}{handcount})";
                }
                &build($cl, $id);
                return;
            }
        }
    }
        
    # there's nothing for me to do!
    $client{$cl}{idle} = 1;
    slog "Client $client{$cl}{client} is idle.";

    my $idle_clients = 0;
    for my $c (&build_clients) {
        if ($client{$c}{idle}) {
            $idle_clients++;
        }
    }

    dlog sprintf "%d / %d clients are idle.", $idle_clients, scalar &build_clients;
}

sub assign_abandoned_builds
{
    if ($abandoned_builds and $idle_clients) {
        for my $id (&bigbuilds) {
            if (!$builds{$id}{assigned}) {
                for my $c (sort {$client{$b}{speed} <=> $client{$a}{speed}} &build_clients) {
                    if (!scalar keys %{$client{$c}{queue}}) {
                        $client{$c}{queue}{$id} = $builds{$id}{score};
                        $abandoned_builds -= 1;
                        $idle_clients -= 1;
                        &start_next_build($c);
                    }
                }
            }
        }
    }
}

sub estimate_eta
{
    my %buildhost;

    for my $cl (build_clients()) {
        my $cspeed = $client{$cl}{speed};
        next if (not $cspeed);

        my ($t, $id) = client_eta($cl);
        my $eta = int(time + $t);
        if ($t) {
            if (not defined $buildstimes{$id} or
                $buildtimes{$id} > $eta)
            {
                $buildtimes{$id} = $eta;
                $buildhost{$id} = $client{$cl}{$client};
            }
        }
        
        for $id (sort {$builds{$b}{score} <=> $builds{$a}{score}}
                   $keys %{$client{$cl}{queue}})
        {
            $eta += int($build{$id}{score} / $cspeed);
            if (not defined $buildstimes{$id} or
                $buildtimes{$id} > $eta)
            {
                $buildtimes{$id} = $eta;
            }
        }
    }

    my @slist = sort {$buildtimes{$b} <=> $buildtimes{$a}} @buildids;
    my $last = $slist[0];
    dlog sprintf("Last build ($last:$buildhost{$last}) is expected to complete in %d seconds",
                 $buildtimes{$last} - time);
}

my $stat;

# Control commands:
#
# BUILD [rev] - start a build immediately, or fail if one is already in
# progress
#

sub control {
    my ($rh, $cmd) = @_;
    chomp $cmd;
    slog "Commander says: $cmd";

    if($cmd =~ /^BUILD (\d+)/) {
        if(!$buildround) {
            &startround($1);
        }
        else {
            $nextround = $1;
        }
        command $rh, "OK!";
    }
    elsif ($cmd =~ /^UPDATE (.*?) (\d+)/) {
        for my $cl (&build_clients) {
            if ($clients{$cl}{client} eq "$1") {
                &update_client($cl, $2);
            }
        }
    }
}

# Master socket for receiving new connections
my $server = new IO::Socket::INET(
	LocalPort => $test ? 19998 : 19999,
	Proto => "tcp",
	Listen => 25,
	Reuse => 1)
or die "socket: $!\n";

getbuilds("builds");
db_connect();

my $debug;

# Add the master socket to select mask
my $read_set = new IO::Select();
$read_set->add($server);
$conn{$server->fileno} = { type => 'master' };

readblockfile();

print "Server starts. See 'logfile'.\n";

slog "Server starts";
dlog "=================== Server starts ===================";

# Main loop active until ^C pressed
my $alldone = 0;
$SIG{KILL} = sub { slog "Killed"; exit; };
$SIG{INT} = sub { slog "Received interrupt"; $alldone = 1; };
$SIG{__DIE__} = sub { slog(sprintf("Perl error: %s", @_)); };
while(not $alldone) {
    my @handles = sort map $_->fileno, $read_set->handles;
    warn "waiting on (@handles)\n" if($debug);
    my ($rh_set, $timeleft) =
        IO::Select->select($read_set, undef, undef, 1);

    foreach my $rh (@$rh_set) {
        if (not exists $conn{$rh->fileno}) {
            slog "Fatal: Untracked rh!";
            die "untracked rh";
        }
        my $type = $conn{$rh->fileno}{type};

        if ($type eq 'master') {
            my $new = $rh->accept or die;
            $read_set->add($new);
            $conn{$new->fileno} = { type => 'rbclient' };
            $new->blocking(0) or die "blocking: $!";
            $client{$new->fileno}{'socket'} = $new;
        }
        else {
            my $data;
            my $fileno = $rh->fileno;
            my $len = $rh->read($data, 512);

            if ($len) {
                my $cmd = \$client{$fileno}{'cmd'};
                $$cmd .= $data;
                while (1) {
                    my $pos = index($$cmd, "\n");
                    last if ($pos == -1);
                    if ($type eq 'commander') {
                        &control($rh, $$cmd);
                    }
                    else {
                        &parsecmd($rh, $$cmd);
                        $type = $conn{$rh->fileno}{type};
                    }
                    $$cmd = substr($$cmd, $pos+1);
                }
            }
            else {
                if ($type eq 'commander') {
                    slog "Commander left";                
                    delete $conn{$fileno};
                    $read_set->remove($rh);
                    $rh->close;
                    $commander=0;
                }
                else {
                    $client{$fileno}{fine} = 1;
                    $client{$fileno}{'bad'}="connection lost";
                }
            }
        }
    }

    # loop over the clients and close the bad ones
    foreach my $cl (&build_clients) {

        my $err = $client{$cl}{'bad'};
        if($err) {
            my $cli = $client{$cl}{'client'};

            slog "Disconnect: client $cli reason $err";
            $client{$cl}{fine} = 0;
            client_gone($cl);
            my $rh = $client{$cl}{'socket'};
            if ($rh) {
                $read_set->remove($rh);
                $rh->close;
            }
            else {
                slog "!!! No rh to delete for client $cli";
            }
            delete $client{$cl};
            delete $conn{$cl};

            # we lost a client, re-allocate builds
            if ($buildround) {
                #&bestfit_builds(0);
            }
        }
    }

    assign_abandoned_builds();

    checkclients();
    readblockfile();
}
warn "exiting.\n";
