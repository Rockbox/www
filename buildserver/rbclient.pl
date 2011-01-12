#!/usr/bin/perl -s
#
# $Id$
#

#use strict;
use IO::Socket;
use IO::Select;
use IO::File;
use IO::Pipe;
use File::Basename;
use File::Path;
use POSIX 'strftime';
use POSIX ":sys_wait_h";

my $perlfile = "rbclient.pl";
my $revision = 36;
my $cwd = `pwd`;
chomp $cwd;

sub tprint {
    my $line = strftime("%F %T ", localtime()) . $_[0];
    print $line;
    if (open LOG, ">>$cwd/rbclient.log") {
        print LOG $line;
        close LOG;
    }
}

# read -parameters
my $username = $username;
my $password = $password;
my $clientname = $clientname;
my $archlist = $archlist;
my $buildmaster = $buildmaster || 'buildmaster.rockbox.org';
my $port = $port || 19999;
my $ulspeed = $ulspeed || 0;
my $commandhook = $commandhook || '';

my $upload = "http://$buildmaster/upload.pl";

my ($probecores) = &probecores;
my $cores = $cores || $probecores;

# Modify the speed accordingly if not using all cores
if ($cores ne $probecores) {
    $speed = $cores * ($speed / $probecores);
}

my $cpu = `uname -m`;
chomp $cpu;
my $os = `uname -s`;
chomp $os;

if ($cpu eq "i686" or $cpu eq "i386" or $cpu eq "armv5tel") {
    $bits = 32;
}
elsif ($cpu eq "x86_64") {
    $bits = 64;
}
else {
    printf("Unrecognised cpu $cpu - please fix rbclient.pl to know of this\n");
    exit 22;
}

&readconfig($config) if ($config);

unless ($username and $password and $archlist and $clientname) {
    print <<MOO
Insufficient parameters. You must specify:

-username=[user]
  This is your user name given to you by the server admins

-password=[password]
  The secret password given to you by the server admins

-clientname=[client name]
  The unique name of this particular instances of your build clients. After
  all, you at least run one on your desktop, one on your laptop and one in
  your toaster. Right?

-archlist=[list,of,archs]
  May include arm,m68k,sh,sdl,mipsel and should be a comma-separated list with
  no spaces

optional setting: 

-cores=[num]
  Override rbclient\'s probed results

-buildmaster=[host]
  Connect to this given server instead of the default.

-ulspeed=[speed]
  Limit upload speed to max [speed] kilobytes per second.

-commandhook=[script]
  Run this script whenever a command comes in, with the command itself as the
  first argument, and the command parameters in the second argument. This can
  be used for fancy monitoring of the client.

You can also specify -config=file where parameters are stored as 'label: value'

MOO
;
    exit 22;
}

&testsystem();

if (not -d "builds") {
    mkdir "builds";
}
# no localized messages, please
$ENV{LC_ALL} = 'C';

beginning:

tprint "Starting client $clientname, revision $revision, cores $cores\n";

my $sock;

while (1) {
    $sock = IO::Socket::INET->new(PeerAddr => $buildmaster,
                                  PeerPort => $port,
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

tprint "HELLO $revision $archlist $auth $clientname $cpu $bits $os\n";
print $sock "HELLO $revision $archlist $auth $clientname $cpu $bits $os\n";

my $busy = 0;
my %builds = ();
my $buildnum = 0;
my $lastcomm = time();
my $input;

$SIG{INT} = sub {
    warn "received interrupt.\n";
    for my $id (keys %builds) {
        if ($builds{$id}{pid}) {
            &killchild($id);
        }
    }                
    exit -1;
};


while (1) {
    my ($rh_set, $timeleft) =
        IO::Select->select($read_set, undef, undef, 1);

    foreach my $rh (@$rh_set) {
        if ($conntype{$rh->fileno} eq "socket") {
            #print "Got from socket\n";
            $lastcomm = time();
            my $data = <$rh>;
            if (length $data) {
                $input .= $data;
                
                while (1) {
                    my $pos = index($input, "\n");
                    last if ($pos == -1);
                    my $line = substr($input, 0, $pos);
                    &parsecmd($line);
                    $input = substr($input, $pos+1);
                }
            }
            else {
                # socket dropped. stop all builds and restart
                tprint "Server socket disconnected! Cleanup and restart.\n";
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
            my $data = <$rh>;
            if (length $data) {
                if ($data =~ /uploading (.*?) (\d+)/) {
                    # client has started uploading
                    my ($id, $pid) = ($1, $2);
                    tprint "child $id ($pid) is uploading\n";
                    print $sock "UPLOADING $id\n";
                    
                    # we're no longer busy
                    $busy -= $builds{$id}{cores};
                    $builds{$id}{cores} = 0;
                    print $sock "GIMMEMORE\n";
                }
                elsif ($data =~ /done (.*?) (\d+) (\d+) (\d+) (.*)/) {
                    my ($id, $pid, $ultime, $ulsize, $status) = ($1, $2, $3, $4, $5);

                    waitpid $pid, 0;
                    $read_set->remove($rh);
                    delete $conntype{$rh->fileno};
                    close $rh;

                    my $dir = "$cwd/builds/build-$id";
                    if (-d $dir) {
                        rmtree $dir;
                    }

                    if ($status eq "ok") {
                        tprint "Completed build $id\n";
                        my $timespent = time() - $builds{$id}{started};
                        print $sock "COMPLETED $id $timespent $ultime $ulsize\n";
                    }
                    else {
                        tprint "Failed build $id: Status $status\n";
                    }

                    delete $builds{$id};
                }
            }
            else {
                tprint sprintf "Child %d died unexpectedly!\n", $rh->fileno;
                exit;
            }
        }
        else {
            die "Got from other (%d)\n", $rh->fileno;
        }
    }

    if ($lastcomm + 60 < time()) {
        tprint "Server connection stalled. Exiting in 5s...\n";
        close $sock;
        sleep 5;
        exit;
    }

}

#################################################

sub startbuild
{
    my ($id) = @_;

    tprint "Starting build $id\n";

    # make mother/child pipe
    my $pipe = new IO::Pipe();
    $builds{$id}{pipe} = $pipe;

    # fix svn
    my $buf = `svnversion`;
    my $rev;
    if ($buf =~ /(\d\w+)/) {
        $rev = $1;
        if ($rev =~ /M/) {
            tprint "*** Your source tree is modified! Clean it up and restart.\n";
            exit 22;
        }
    }
    if ($rev != $builds{$id}{rev}) {
        # (using system() to make stderr messages appear on client console)
        system("svn up -q -r $builds{$id}{rev} $log");
    }
    if ($?) { # abort if svn failed
        tprint "*** Subversion error!\n";
        return;
    }

    # start timer
    $builds{$id}{started} = time();

    my $pid = fork;
    if ($pid) {
        # mother
        $builds{$id}{pid} = $pid;
        $pipe->reader();
        $read_set->add($pipe);
        $conntype{$pipe->fileno} = 'pipe';

        push @children, $pid;
        $busy += $builds{$id}{cores};
    }
    else {
        # child
        setpgrp;
        $pipe->writer();
        $pipe->autoflush();
        my $starttime = time();
        # It is important that we name the uploaded files
        # [client]-[user]-[build].log/zip as otherwise the server won't
        # find/use it
        my $base="$clientname-$username-$id";

        chdir "builds";
        if (-d "build-$id") {
            rmtree "build-$id";
        }
        mkdir "build-$id";
        my $logfile = "$cwd/builds/build-$id/$base.log";
        my $log = ">> $logfile 2>&1";
        
        open DEST, ">$logfile";
        # to keep all other scripts working, use the same output as buildall.pl:
        print DEST "Build Start Single\n";
        
        printf DEST "Build Date: %s\n", strftime("%Y%m%dT%H%M%SZ", gmtime);
        print DEST "Build Type: $id\n";
        print DEST "Build Dir: $cwd/builds/build-$id\n";
        print DEST "Build Server: $clientname-$username\n";
        close DEST;

        chdir "build-$id";
        my $args = $builds{$id}{confargs};
        $args =~ s|,| |g;
        `$cwd/tools/configure $args $log`;
        if ($builds{$id}{cores} > 1) {
            my $c = $cores + 1;
            `nice make -k -j$c $log`;
        }
        else {
            `nice make -k $log`;
        }

        # report
        open DEST, ">>$logfile";
        if (-f $builds{$id}{result}) {
            print DEST "Build Status: Fine\n";
        }
        else {
            print DEST "Build Failure: No '$builds{$id}{result}' was produced.\n";
            print DEST "Build Status: Failed\n";
        }
        my $tooktime = time() - $starttime;
        print DEST "Build Time: $tooktime\n";
        close DEST;

        print $pipe "uploading $id $$\n";
        &upload($logfile);

        my ($ultime, $ulsize) = (0,0);
        my $zip = $builds{$id}{zip};
        if (-f $builds{$id}{result} and $zip ne "nozip") {
            tprint "Making $id zip\n";
            `nice make zip $log`;
            
            if (-f "rockbox.zip") {
                my $newzip = "$base.zip";
                if (rename "rockbox.zip", $newzip) {
                    my $ulstart = time();
                    &upload($newzip);
                    $ultime = time() - $ulstart;
                    $ulsize = (stat($newzip))[7];
                }
            }
            else {
                tprint "?? no rockbox.zip\n";
                print $pipe "done $id $$ 0 0 nozip\n";
                close $pipe;
                exit;
            }
        }

        tprint "child: $id ($$) done\n";
        print $pipe "done $id $$ $ultime $ulsize ok\n";
        close $pipe;
        exit;
    }
}

sub upload
{
    my ($file) = @_;
    tprint "Uploading $file...\n";
    if (not -f $file) {
        tprint "$file: no such file\n";
        return;
    }

    my $limit;
    if ($ulspeed) {
        $limit = "--limit-rate ${ulspeed}k";
    }

    `curl $limit -s -F upfile=\@$file $upload`;
}

sub probecores
{
    if($^O eq "darwin") {
        my $cores = `sysctl -n hw.ncpu`;
        return $cores;
    }
    else {
        open CPUINFO, "</proc/cpuinfo" or return 0;
        my @cores = grep /^processor/i, <CPUINFO>;
        close CPUINFO;
    
        return (scalar @cores);
    }
}
    
sub _HELLO
{
    if ($_[0] ne "ok") {
        tprint "HELLO failed: @_\n";
        close $sock;
        sleep 10;
        exit;
    }
}

sub _COMPLETED
{
}

sub _UPLOADING
{
}

sub _GIMMEMORE
{
}

sub PING
{
    my ($arg) = @_;
    print $sock "_PING $arg\n";
}

sub CANCEL
{
    my ($id) = @_;

    &killchild($id);

    print $sock "_CANCEL\n";

    if ($busy < $cores) {
        print $sock "GIMMEMORE\n";
    }
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
    $builds{$id}{cores} = $mt eq "mt" ? $cores : 1;
    $builds{$id}{result} = $result;
    $builds{$id}{seqnum} = $buildnum++;

    print $sock "_BUILD $id\n";

    &startbuild($id);
}

sub UPDATE
{
    my ($rev) = @_;
    tprint "Update to $rev\n";

    `curl -o $perlfile.new "http://svn.rockbox.org/viewvc.cgi/www/buildserver/$perlfile?revision=$rev"`;
    
    # This might fail, but runclient.sh will save us
    rename("$perlfile.new", $perlfile);

    print $sock "_UPDATE $rev\n";
    close $sock;
    sleep 1;
    exit;
}

sub MESSAGE
{
    tprint "Server message: @_\n";
    print $sock "_MESSAGE\n";
}

sub parsecmd
{
    my ($cmdstr)=@_;
    my %functions = ('_HELLO', 1,
                     '_COMPLETED', 1,
                     '_UPLOADING', 1,
                     '_GIMMEMORE', 1,
                     'BUILD', 1,
                     'PING', 1,
                     'UPDATE', 1,
                     'CANCEL', 1,
                     'MESSAGE', 1);
    
    if($cmdstr =~ /^([_A-Z]*) *(.*)/) {
        my $func = $1;
        my $rest = $2;
        chomp $rest;
        #print "$func $rest\n";

        if (defined $functions{$func}) {
            &$func($rest);
        }
        else {
            tprint "Unknown command '$func'\n";
        }
        if($commandhook ne '') {
            system(sprintf("%s '%s' '%s'",$commandhook,$func,$rest));
        }
    }
    else {
        tprint "Unrecognized command '$cmdstr'\n";
    }
}

sub testsystem
{
    # check compilers
    %compilers = (
        "arm", ["arm-elf-gcc", "4.0.3"],
        "arm-eabi-gcc444", ["arm-elf-eabi-gcc", "4.4.4"],
        "sh", ["sh-elf-gcc", "4.0.3"],
        "m68k", ["m68k-elf-gcc", "3.4.6"],
        "m68k-gcc452", ["m68k-elf-gcc", "4.5.2"],
        "mipsel", ["mipsel-elf-gcc", "4.1.2"],
        "sdl", ["sdl-config", ".*"],
        );

    for (split ',', $archlist) {
        my $p = `$compilers{$_}[0] --version`;
        if (not $p =~ /$compilers{$_}[1]/) {
            tprint "You specified arch $_ but don't have (the correct version ($compilers{$_}[1]) of) $compilers{$_}[0] in your path!\n";
            exit 22;
        }
    }

    # check curl
    my $p = `which curl`;
    if (not $p =~ m|^/|) {
        tprint "I couldn't find 'curl' in your path.\n";
        exit 22;
    }

    # check curl
    my $p = `which zip`;
    if (not $p =~ m|^/|) {
        tprint "I couldn't find 'zip' in your path.\n";
        exit 22;
    }

    # check perlfile
    if (not -w $perlfile) {
        tprint "$perlfile must be located in the current directory, and writable by current\nuser, to allow automatic updates.";
        exit 22;
    }

    # check an upgrade file
    if (-e "$perlfile.new") {
        tprint "An upgrade didn't complete. Rename $perlfile.new to $perlfile\n";
        exit 22;
    }
        
    # check repository
    my @svn = `svn info`;
    my @url = grep(/^URL:/, @svn);
    if ($url[0] =~ m|^URL: svn://svn.rockbox.org/rockbox/(.+)|) {
        my $s = $1;
        if ($s =~ /www/) {
            tprint "Script must be ran in root of a source repository. You are in $s.\n";
            exit 22;
        }
    }

    # check that source tree is unmodified
    my $rev = `svnversion`;
    if ($rev =~ /M/) {
        tprint "Your source tree is modified! Clean it up and restart.\n";
        exit 22;
    }

    # update svn to latest version
    system("svn up");
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

    return if (not defined $builds{$id});

    my $pipe = $builds{$id}{pipe};
    $read_set->remove($pipe);

    $busy -= $builds{$id}{cores};

    my $pid = $builds{$id}{pid};
    if ($pid) {
        kill -15, $pid;
        tprint "Killed build $id\n";
        waitpid $pid, 0;
    }

    my $dir = "$cwd/builds/build-$id";
    if (-d $dir) {
        tprint "Removing $dir\n";
        rmtree $dir;
    }

    delete $builds{$id};
}
