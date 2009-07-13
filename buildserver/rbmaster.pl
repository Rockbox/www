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

# the minimum protocol version supported. The protocol version is provided
# by the client
my $minimumversion = 25;

# if the client is found too old, this is a svn rev we tell the client to
# use to pick an update
my $updaterev = 21850;

# the name of the server log
my $logfile="logfile";

use IO::Socket;
use IO::Select;
use File::Path;
use DBI;
use Time::HiRes qw(gettimeofday tv_interval);
use POSIX 'strftime';

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
#  {'bogomips'}
#

my $started = time();
my $wastedtime = 0; # sum of time spent by clients on cancelled builds

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

    for my $cl (&build_clients) {
        &privmessage($cl, $string);
    }
}

sub slog {
    open(L, ">>$logfile");
    print L strftime("%F %T ", localtime()), $_[0], "\n";
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

            #print "> CANCEL $id ($client{$cl}{client}) after $took seconds\n";

            slog sprintf("Cancel: build $id client %s seconds %d",
                         $client{$cl}{'client'}, $took);

            # tell client to build!
            command $rh, "CANCEL $id";
            $client{$cl}{'expect'}="_CANCEL";
            $num++;

            my $cli = $client{$cl}{'client'};

            unlink <"$uploadpath/$cli-$id"*>;
        }
    }
    if($num) {
        #print "Killed $num remaining $id build!\n";
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

    %builds = ();
    @buildids = ();

    open(F, "<$filename");
    while(<F>) {
        # sdl:nozip:recordersim:Recorder - Simulator:rockboxui:--target=recorder,--ram=2,--type=s
        if($_ =~ /([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):(\d+)/) {
            my ($arch, $zip, $id, $name, $file, $confopts, $score) =
                ($1, $2, $3, $4, $5, $6, $7);
            $builds{$id}{'arch'}=$arch;
            $builds{$id}{'zip'}=$zip;
            $builds{$id}{'name'}=$name;
            $builds{$id}{'file'}=$file;
            $builds{$id}{'confopts'}=$confopts;
            $builds{$id}{'score'}=$score;
            $builds{$id}{'handcount'} = 0; # not handed out to anyone
            $builds{$id}{'done'} = 0; # not done
            $builds{$id}{'uploading'} = 0; # not uploading

            push @buildids, $id;
        }
    }
    close(F);

    my @s = sort {$builds{$b}{score} <=> $builds{$a}{score}} keys %builds;
    $topscore = $builds{$s[0]}{score};
}

sub updateclient {
    my ($cl, $rev) = @_;

    my $rh = $client{$cl}{'socket'};

    # tell client to build!
    command $rh, "UPDATE $rev";
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
    command $rh, "BUILD $args";
    $client{$fileno}{'expect'}="_BUILD";

    #print "Build $args\n";

    slog sprintf("Build: build $id rev $rev client %s",
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

sub _MESSAGE {
    my ($rh, $args) = @_;
    $client{$rh->fileno}{'expect'}="";
}

sub _PING {
    my ($rh, $args) = @_;

    $client{$rh->fileno}{'expect'}="";
    my $t = tv_interval($client{$rh->fileno}{'ping'});
    $t = int($t * 1000);
    if ($t > 1000) {
        #print "Slow _PING from $client{$rh->fileno}{client} ($t ms)\n";
        slog "Slow _PING from $client{$rh->fileno}{client} ($t ms)";
    }
}

sub _UPDATE {
    my ($rh, $args) = @_;

    $client{$rh->fileno}{'expect'}="";
}

sub _CANCEL {
    my ($rh, $args) = @_;

    $wastedtime += $args;

    $client{$rh->fileno}{'expect'}="";
    $client{$rh->fileno}{'building'}--;
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

        #print "Commander attached at $fno\n";
        slog "Commander attached";
        command $rh, "Hello commander";

        $conn{$fno}{type} = "commander";
    }
    elsif(!$bogomips) {
        # send error
        print "Bad HELLO: $args\n";

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
        $client{$fno}{'archlist'} = $archlist;
        $client{$fno}{'cpu'} = $cpu;
        $client{$fno}{'bits'} = $bits;
        $client{$fno}{'os'} = $os;
        $client{$fno}{'bogomips'} = $bogomips;
        $client{$fno}{'socket'} = $rh;
        $client{$fno}{'expect'} = ""; # no response expected yet
        $client{$fno}{'builds'} = ""; # none so far
        $client{$fno}{'bad'} = 0; # not bad!
        $client{$fno}{'avgscore'} = 0;

        &get_clientscore($fno);

        # send OK
        command $rh, "_HELLO ok";

        #print "Joined: $args\n";
        my $score = $client{$fno}{avgscore};
        slog "Joined: client $cli user $user arch $archlist score $score";

        privmessage $fno, sprintf  "Welcome $cli. Your score $score puts you in the %s category.", ($score > $topscore) ? "fast" : "slow";
        if($version < $minimumversion) {
            updateclient($fno, $updaterev);
            $client{$fno}{'bad'}="asked to update";
        }
        else {
            $client{$fno}{'fine'} = 1;
            handoutbuilds($fno);
        }
    }
}

sub UPLOADING {
    my ($rh, $args) = @_;
    $builds{$args}{uploading} = 1;
    command $rh, "_UPLOADING";
    #slog "Upload: $client{$rh->fileno}{'client'} uploads $args\n";
}

sub GIMMEMORE {
    my ($rh, $args) = @_;
    my $cli = $client{$rh->fileno}{'client'};

    #print "< GIMMEMORE ($cli)\n";
    command $rh, "_GIMMEMORE $id";

    &handoutbuilds($rh->fileno);
}

sub COMPLETED {
    my ($rh, $args) = @_;
    my $cli = $client{$rh->fileno}{'client'};

    my ($id, $took, $ultime, $ulsize) = split(" ", $args);

    #print "< COMPLETED $id\n";

    if($builds{$id}{'done'}) {
        # This is a client saying this build is completed although it has
        # already been said to be. Most likely because we killed this build
        # already but the client didn't properly obey!
        slog "Duplicate completion from $cli. $id is already complete";
        #print "ALERT: this build was already completed!!!\n";
        return;
    }

    # mark this as not building anymore
    $client{$rh->fileno}{'building'}--;

    # cut out this build from this client
    $client{$rh->fileno}{'builds'}=~ s/-$id-//;

    $builds{$id}{'handcount'}--; # one less that builds this
    $builds{$id}{'done'}=1;
    $builds{$id}{'uploading'}=0;

    # send OK
    command $rh, "_COMPLETED $id";

    # assign client score
    $client{$rh->fileno}{roundscore} += $builds{$id}{score};

    my $uplink = 0;
    if ($ulsize and $ultime) {
        $uplink = $ulsize / $ultime / 1024;
    }
    slog sprintf("Completed: build $id client %s seconds %d uplink %d score %d",
                 $cli, $took, $uplink, $client{$rh->fileno}{roundscore});

    if (&check_fatal_error(sprintf("$uploadpath/%s-%s.log", $cli, $id))) {
        slog "$cli is out of diskspace! Disabling client.";
        privmessage $rh->fileno, "Your are out of disk space. You have been disabled.";
        $client{$rh->fileno}{'fine'} = 0;
        return;
    }

    # now kill this build on all clients still building it
    my $kills = kill_build($id);

    # log this build in the database
    &db_submit($buildround, $id, $cli, $took,
               $client{$rh->fileno}{'bogomips'}, $ultime, $ulsize);

    my $base=sprintf("$uploadpath/%s-%s", $cli, $id);
                     
    if($builds{$id}{'zip'} eq "zip") {
        # if a zip was included in the build
        rename("$base.zip", "$store/rockbox-$id.zip");
    }
    # now move over the build log
    rename("$base.log", "$store/$buildround-$id.log");

    if($rb_eachcomplete) {
        my $start = time();
        system("$rb_eachcomplete $id $cli");
        if ((time() - $start) > 1) {
            slog "WARNING: rb_eachcomplete script is taking too long!";
        }
    }
}

sub check_fatal_error
{
    my ($file) = @_;
    if (open F, "<$file") {
        if (grep /No space left on device/, <F>) {
            close F;
            return 1;
        }
        close F;
    }
    return 0;
}
sub update_clientscores
{
    return unless ($db);

    for my $cl (&build_clients) {
        my $score = $client{$cl}{roundscore};
        $score = 0 if (!$score);
        $setscore_sth->execute($client{$cl}{client}, $buildround, $score, $buildround, $score) or
            warn "DBI: Can't execute statement: ". $setscore_sth->errstr;
    }
}

sub get_clientscore
{
    return unless ($db);

    my ($cl) = @_;

    my $rows = $getscore_sth->execute($client{$cl}{client});
    if ($rows > 0) {
        my ($score, $count) = $getscore_sth->fetchrow_array();
        $client{$cl}{avgscore} = int($score / $count);
    }
}

sub db_connect
{
    my $dbpath = 'DBI:mysql:rockbox';
    $db = DBI->connect($dbpath, $rb_dbuser, $rb_dbpwd) or
        warn "DBI: Can't connect to database: ". DBI->errstr;

    # prepare some statements for later execution:

    $submit_update_sth = $db->prepare("UPDATE builds SET client=?,timeused=?,bogomips=?,ultime=?,ulsize=? WHERE revision=? and id=?") or
        warn "DBI: Can't prepare statement: ". $db->errstr;

    $submit_new_sth = $db->prepare("INSERT INTO builds (revision,id) VALUES (?,?) ON DUPLICATE KEY UPDATE client='',timeused=0,bogomips=0,ultime=0,ulsize=0") or
        warn "DBI: Can't prepare statement: ". $db->errstr;

    $setscore_sth = $db->prepare("INSERT INTO clients (name, lastrev, totscore, builds) VALUES (?,?,?,1) ON DUPLICATE KEY UPDATE lastrev=?,totscore=totscore+?,builds=builds+1") or
        warn "DBI: Can't prepare statement: ". $db->errstr;

    $getscore_sth = $db->prepare("SELECT totscore, builds FROM clients WHERE name=?") or
        warn "DBI: Can't prepare statement: ". $db->errstr;
}

sub db_submit
{
    return unless ($rb_dbuser and $rb_dbpwd);

    my ($revision, $id, $client, $timeused, $bogomips, $ultime, $ulsize) = @_;
    if ($client) {
        $submit_update_sth->execute($client, $timeused, $bogomips, $ultime, $ulsize, $revision, $id) or
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
    return $client{$b}{'avgscore'} <=> $client{$a}{'avgscore'};
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

    getbuilds("builds");

    my $num_clients = scalar &build_clients;
    my $num_builds = scalar @buildids;

    slog "New round: $num_clients clients $num_builds builds rev $rev topscore $topscore";

    message sprintf "New build round started. Revision $rev, $num_builds builds, $num_clients clients.";

    $buildround=$rev;
    $buildstart=time();
    $wastedtime = 0;
    $phase = 1;
    $countdown = 0;

    resetbuildround();

    # fill db with builds to be done
    for my $id (@buildids) {
        &db_submit($buildround, $id);
    }

    # clear zip files, to avoid old ones remaining
    `rm -f data/rockbox-*.zip`;

    handoutbuilds(&build_clients);
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
    #print "END of a build round, $took seconds, skipped $inp builds\n";
    slog "End of round $buildround: skipped $inp seconds $took wasted $wastedtime";

    message sprintf "Build round completed after $took seconds.";

    resetbuildround();

    # clear upload dir
    rmtree( $uploadpath, {keep_root => 1} );

    &update_clientscores();

    if($rb_buildround) {
        system("$rb_buildround $buildround");
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
                print "ALERT: waiting ${t}s for $exp from client $client{$cl}{client}!\n";
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
    if(!$buildround) {
        # don't hand out builds unless we're in a build round
        return;
    }

    my @scl = sort sortclients @_;
    my @blist = @buildids;
    my $done=0;

    for my $cl (@scl) {

        next if ($client{$cl}{fine} == 0);
        next if ($conn{$cl}{type} eq "commander");

        $done =0;
        my $found=0;

        if ($client{$cl}{avgscore} > $topscore) {
            @blist = sort fastclient @blist;
        }
        else {
            @blist = sort slowclient @blist;
        }

        # time to go through the builds and give to clients
        while (scalar @blist) {
            my $id = pop @blist;

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

        if($done >= scalar @buildids) {
            endround();
            last;
        }
    }

    my $und = builds_undone();
    my $inp = builds_in_progress();
    my $bc = scalar(&build_clients);

    # only display this stat if different than last time
    my $thisstat="$und-$inp-$bc";
    if($buildround and $thisstat ne $stat) {
        print "$und builds not complete, $bc clients. $inp builds in progress\n";
        $stat = $thisstat;
    }

    if ($und < 10 and $countdown != $und) {
        message sprintf "$und build%s left...", ($und > 1) ? "s" : "";
        $countdown = $und;
    }

    my $unhanded = 0;
    for my $id (@buildids) {
        $unhanded += 1 if ($builds{$id}{handcount} == 0);
    }
    if ($unhanded == 0 and $phase == 1) {
        $phase = 2;
        slog "All builds are now handed out. Speculative building commencing.";
        message "All builds are now handed out. Speculative building commencing.";
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
        }
        else {
            $nextround = $1;
        }
        command $rh, "OK!";
    }
}

# Master socket for receiving new connections
my $server = new IO::Socket::INET(
	LocalPort => 19999,
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

print "Server starts\n";

slog "Server starts";

# Main loop active until ^C pressed
my $alldone = 0;
$SIG{INT} = sub { warn "received interrupt\n"; $alldone = 1; };
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
        }
        elsif ($type eq 'commander') {
            my $data;
            my $len = $rh->read($data, 512);

            if ($data) {
                chomp $data;
                control($data, $rh);
            }
            else {
                #print "Commander left\n";
                slog "Commander left";                
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
    foreach my $cl (&build_clients) {

        my $err = $client{$cl}{'bad'};
        if($err) {
            my $cli = $client{$cl}{'client'};

            printf("Client disconnect ($err), removing client $cli on %d\n",
                   $cl);
            slog "Disconnect: client $cli reason $err";
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
        }
    }

    checkclients();
}
warn "exiting.\n";
