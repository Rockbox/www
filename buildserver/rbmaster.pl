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
my $minimumversion = 29;

# if the client is found too old, this is a svn rev we tell the client to
# use to pick an update
my $updaterev = 21970;

# the name of the server log
my $logfile="logfile";

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
my $speedlimit = 50; # >50 points/sec is a "fast" machine

sub slog {
    if (open(L, ">>$logfile")) {
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
        # cut out this build from this client
        if($client{$cl}{'builds'}=~ s/-$id-//) {
            my $rh = $client{$cl}{'socket'};

            my $took = time() - $client{$cl}{'btime'}{$id};

            slog sprintf("Cancel: build $id client %s seconds %d",
                         $client{$cl}{'client'}, $took);

            $wastedtime += $took;

            # tell client to cancel!
            command $rh, "CANCEL $id";
            $client{$cl}{'expect'}="_CANCEL";
            $num++;

            my $cli = $client{$cl}{'client'};

            unlink <"$uploadpath/$cli-$id"*>;
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

    $setlastrev_sth->execute($client{$fileno}{'client'}, $buildround, $buildround);
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

    #if ($client{$rh->fileno}{'expect'} ne "_PING") {
    #    slog sprintf "Got unexpected _PING from $client{$rh->fileno}{client} when waiting for '%s'.", $client{$rh->fileno}{'expect'};
    #}

    $client{$rh->fileno}{'expect'}="";
    my $t = tv_interval($client{$rh->fileno}{'ping'});
    $t = int($t * 1000);
    if ($t > 2000) {
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
        $client{$fno}{'archlist'} = $archlist;
        $client{$fno}{'cpu'} = $cpu;
        $client{$fno}{'bits'} = $bits;
        $client{$fno}{'os'} = $os;
        $client{$fno}{'socket'} = $rh;
        $client{$fno}{'expect'} = ""; # no response expected yet
        $client{$fno}{'builds'} = ""; # none so far
        $client{$fno}{'bad'} = 0; # not bad!
        $client{$fno}{'blocked'} = $blocked{$cli};

        # send OK
        command $rh, "_HELLO ok";

        my $speed = &getspeed($cli);

        $client{$fno}{speed} = $speed;

        if ($client{$fno}{blocked}) {
            slog "Blocked: client $cli blocked due to: $client{$fno}{blocked}";
            privmessage $fno, sprintf  "Hello $cli. Your build client has been temporarily blocked by the administrators due to: $client{$fno}{blocked}. Please go to #rockbox to enable your client again.";
        }
        else {
            slog "Joined: client $cli arch $archlist speed $speed";
            privmessage $fno, sprintf  "Welcome $cli. Your speed $speed points/sec puts you in the %s category.", ($speed > $speedlimit) ? "fast" : "slow";
        }
        
        if($version < $minimumversion) {
            updateclient($fno, $updaterev);
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

    command $rh, "_GIMMEMORE $id";

    &handoutbuilds($rh->fileno);
}

sub COMPLETED {
    my ($rh, $args) = @_;
    my $cli = $client{$rh->fileno}{'client'};

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

    # mark this client as not building anymore
    $client{$rh->fileno}{'building'}--;

    # cut out this build from this client
    $client{$rh->fileno}{'builds'}=~ s/-$id-//;

    my $uplink = 0;
    if ($ulsize and $ultime) {
        $uplink = $ulsize / $ultime / 1024;
    }
    slog sprintf("Completed: build $id client %s seconds %d uplink %d speed %d",
                 $cli, $took, $uplink, $builds{$id}{score}/($took - $ultime));

    my $msg = &check_log(sprintf("$uploadpath/%s-%s.log", $cli, $id));
    if ($msg) {
        slog "Fatal build error: $msg. Disabling client.";
        privmessage $rh->fileno, "Fatal build error: $msg. You have been temporarily disabled.";
        $client{$rh->fileno}{'blocked'} = $msg;
        return;
    }

    # mark build completed
    $builds{$id}{'handcount'}--; # one less that builds this
    $builds{$id}{'done'}=1;
    $builds{$id}{'uploading'}=0;

    # now kill this build on all clients still building it
    my $kills = kill_build($id);

    # log this build in the database
    &db_submit($buildround, $id, $cli, $took, $ultime, $ulsize);

    my $base=sprintf("$uploadpath/%s-%s", $cli, $id);
                     
    if($builds{$id}{'zip'} eq "zip") {
        # if a zip was included in the build
        rename("$base.zip", "$store/rockbox-$id.zip");
    }
    # now move over the build log
    rename("$base.log", "$store/$buildround-$id.log");

    if($rb_eachcomplete) {
        my $start = time();
        system("$rb_eachcomplete $id $cli $buildround");
        my $took = time() - $start;
        if ($took > 1) {
            slog "rb_eachcomplete took $took seconds";
        }
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
    slog "End of round $buildround: skipped $inp seconds $took wasted $wastedtime";

    message sprintf "Build round completed after $took seconds.";

    resetbuildround();

    # clear upload dir
    rmtree( $uploadpath, {keep_root => 1} );

    if($rb_roundend) {
        my $start = time();
        system("$rb_roundend $buildround");
        my $took = time() - $start;
        if ($took > 1) {
            slog "rb_roundend took $took seconds";
        }
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

sub unhanded {
    my $unhanded = 0;
    if ($phase < 2) {
        for my $id (@buildids) {
            if ($builds{$id}{handcount} > 1) {
                $phase = 2;
                message "Speculative building now commencing.";
                last;
            }
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

        next if ($client{$cl}{blocked});
        next if ($client{$cl}{fine} == 0);
        next if ($conn{$cl}{type} eq "commander");

        $done =0;
        my $found=0;

        if ($client{$cl}{speed} > $speedlimit) {
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
            slog sprintf("Alert: No build found suitable for %s",
                   $client{$cl}{'client'});
        }

        if($done >= scalar @buildids) {
            endround();
            last;
        }
    }

    &unhanded();

    my $und = builds_undone();
    my $inp = builds_in_progress();
    my $bc = scalar(&build_clients);

    # only display this stat if different than last time
    my $thisstat="$und-$inp-$bc";
    if($buildround and $thisstat ne $stat) {
        #slog "$und builds not complete, $bc clients. $inp builds in progress";
        $stat = $thisstat;
    }

    if ($und < 10 and $countdown != $und) {
        message sprintf "$und build%s left...", ($und > 1) ? "s" : "";
        $countdown = $und;
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

readblockfile();

print "Server starts. See 'logfile'.\n";

slog "Server starts";

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
    readblockfile();
}
warn "exiting.\n";
