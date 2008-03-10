#!/usr/bin/perl
use threads;
use threads::shared;

my $src="/home/dast/src/rockbox";

#******** Config options **********

my $sshopts="-oConnectTimeout=15 -oCheckHostIP=no -oStrictHostKeyChecking=no".
    " -oServerAliveInterval=30";

# config.pm has the @servers array with all the servers and info about what
# builds they can do

# The target that's listed first is preferred. Smart ordering speeds up the
# building :)
# Append "/[portnumber]" to the server name to use non-default port numbers

require "config.pm";

# these builds are offered as bleeding edge builds:
my %bleeding =
    ('build-player' => 1,
     'build-recorder' => 1,
     'build-recorder8mb' => 1,
     'build-fmrecorder' => 1,
     'build-recorderv2' => 1,
     'build-ondiofm' => 1,
     'build-ondiosp' => 1,
     'build-h100' => 1,
     'build-h120' => 1,
     'build-h300' => 1,
     'build-ipodcolor' => 1,
     'build-ipodnano' => 1,
     'build-ipod4gray' => 1,
     'build-ipodvideo' => 1,
     'build-ipodvideo64mb' => 1,
     'build-ipod3g' => 1,
     'build-iaudiox5' => 1,
     'build-iaudiom5' => 1,
     'build-ipodmini2g' => 1,
     'build-ipodmini1g' => 1,
     'build-h10' => 1,
     'build-h10_5gb' => 1,
     'build-sansae200' => 1,
     'build-gigabeatf' => 1,
     );

my @builds : shared = (
    "sdl:build-recordersim:Recorder - Simulator:rockboxui:recorder\\n2\\ns\\n",
    "sh:build-recorder:Recorder - Normal:ajbrec.ajz:recorder\\n2\\n\\n",
    "sh:build-recorderboot:Recorder - Boot:ajbrec.ajz:recorder\\n2\\nb\\n",
    "sh:build-recorderv2:V2 Recorder - Normal:ajbrec.ajz:recorderv2\\n2\\n\\n",
 
    "sdl:build-playersim:Player - Simulator:rockboxui:player\\n2\\ns\\n",
    "sh:build-player:Player - Normal:archos.mod:player\\n2\\n\\n",
    "sh:build-playerboot:Player - Boot:archos.mod:player\\n2\\nb\\n",
    
    "sh:build-fmrecorder:FM Recorder - Normal:ajbrec.ajz:fmrecorder\\n2\\n\\n",
    "sh:build-fmrecorderboot:FM Recorder - Boot:ajbrec.ajz:fmrecorder\\n2\\nb\\n",
    "sdl:build-fmrecordersim:FM Recorder - Simulator:rockboxui:fmrecorder\\n2\\ns\\n",
    "sh:build-recorder8mb:Recorder - Normal - 8MB:ajbrec.ajz:recorder\\n8\\n\\n",

    "sh:build-ondiosp:Ondio SP - Normal:ajbrec.ajz:ondiosp\\n2\\n\\n",
    "sh:build-ondiospboot:Ondio SP - Boot:ajbrec.ajz:ondiosp\\n2\\nb\\n",
    "sh:build-ondiofm:Ondio FM - Normal:ajbrec.ajz:ondiofm\\n2\\n\\n",
    "sdl:build-ondiofmsim:Ondio FM - Simulator:rockboxui:ondiofm\\n2\\ns\\n",

    "m68k:build-h100:iriver H100 - Normal:rockbox.iriver:h100\\n\\n",
    "m68k:build-h100boot:iriver H100 - Boot:rockbox.iriver:h100\\nb\\n",
    "m68k:build-h120:iriver H120 - Normal:rockbox.iriver:h120\\n\\n",
    "sdl:build-h120sim:iriver H120 - Simulator:rockboxui:h120\\ns\\n",
    "m68k:build-h120boot:iriver H120 - Boot:rockbox.iriver:h120\\nb\\n",

    "m68k:build-h300:iriver H300 - Normal:rockbox.iriver:h300\\n\\n",
    "sdl:build-h300sim:iriver H300 - Simulator:rockboxui:h300\\ns\\n",
    "m68k:build-h300boot:iriver H300 - Boot:rockbox.iriver:h300\\nb\\n",

    "arm:build-ipodnano:iPod Nano - Normal:rockbox.ipod:ipodnano\\n\\n",
    "arm:build-ipodnanoboot:iPod Nano - Boot:bootloader-ipodnano.ipod:ipodnano\\nb\\n",
    "sdl:build-ipodnanosim:iPod Nano - Simulator:rockboxui:ipodnano\\ns\\n",
    "arm:build-ipodcolor:iPod Color - Normal:rockbox.ipod:ipodcolor\\n\\n",
    "arm:build-ipodcolorboot:iPod Color - Boot:bootloader-ipodcolor.ipod:ipodcolor\\nb\\n",
    "sdl:build-ipodcolorsim:iPod Color - Simulator:rockboxui:ipodcolor\\ns\\n",
    
    "sdl:build-iaudiox5sim:iAudio X5 - Simulator:rockboxui:x5\\ns\\n",
    "sdl:build-iaudiom5sim:iAudio M5 - Simulator:rockboxui:m5\\ns\\n",
    "m68k:build-iaudiox5:iAudio X5 - Normal:rockbox.iaudio:x5\\n\\n",
    "m68k:build-iaudiox5boot:iAudio X5 - Boot:rockbox.iaudio:x5\\nb\\n",
    "m68k:build-iaudiom5:iAudio M5 - Normal:rockbox.iaudio:m5\\n\\n",
    "m68k:build-iaudiom5boot:iAudio M5 - Boot:rockbox.iaudio:m5\\nb\\n",

    "arm:build-ipod4gray:iPod 4G Grayscale - Normal:rockbox.ipod:ipod4g\\n\\n",
    "arm:build-ipod4grayboot:iPod 4G Grayscale - Boot:bootloader-ipod4g.ipod:ipod4g\\nb\\n",
    "sdl:build-ipod4graysim:iPod 4G Grayscale - Simulator:rockboxui:ipod4g\\ns\\n",

    'arm:build-ipodvideo:iPod Video - Normal:rockbox.ipod:ipodvideo\n32\n\n',
    'arm:build-ipodvideo64mb:iPod Video 64MB - Normal:rockbox.ipod:ipodvideo\n64\n\n',
    "arm:build-ipodvideoboot:iPod Video - Boot:bootloader-ipodvideo.ipod:ipodvideo\\n32\\nb\\n",
    "sdl:build-ipodvideosim:iPod Video - Simulator:rockboxui:ipodvideo\\n32\\ns\\n",

    "arm:build-ipod3g:iPod 3G - Normal:rockbox.ipod:ipod3g\\n\\n",
    "arm:build-ipod3gboot:iPod 3G - Boot:bootloader-ipod3g.ipod:ipod3g\\nb\\n",

    "arm:build-ipodmini2g:iPod Mini 2G - Normal:rockbox.ipod:ipodmini2g\\n\\n",
    "arm:build-ipodmini2gboot:iPod Mini 2G - Boot:bootloader-ipodmini2g.ipod:ipodmini2g\\nb\\n",
    "sdl:build-ipodmini2gsim:iPod Mini 2G - Simulator:rockboxui:ipodmini2g\\ns\\n",

    "arm:build-ipodmini1g:iPod Mini 1G - Normal:rockbox.ipod:ipodmini\\n\\n",
    "arm:build-ipodmini1gboot:iPod Mini 1G - Boot:bootloader-ipodmini.ipod:ipodmini\\nb\\n",

    "sdl:build-h10sim:iriver H10 - Simulator:rockboxui:h10\\ns\\n",
    "arm:build-h10:iriver H10 - Normal:rockbox.mi4:h10\\n\\n",
    "arm:build-h10_5gb:iriver H10 5GB - Normal:rockbox.mi4:h10_5gb\\n\\n",
    "arm:build-h10boot:iriver H10 - Boot:H10_20GC.mi4:h10\\nb\\n",

    "sdl:build-ifp7xx:iriver IFP7xx - Simulator:rockboxui:ifp7xx\\ns\\n",

    "arm:build-gigabeatf:Toshiba Gigabeat F - Normal:rockbox.gigabeat:gigabeatf\\n\\n",
    "sdl:build-gigabeatfsim:Toshiba Gigabeat F - Simulator:rockboxui:gigabeatf\\ns\\n",
    "arm:build-gigabeatfboot:Toshiba Gigabeat F - Boot:FWIMG01.DAT:gigabeatf\\nb\\n",

    "sdl:build-sansae200sim:SanDisk Sansa e200 - Simulator:rockboxui:e200\\ns\\n",
    "arm:build-sansae200boot:SanDisk Sansa e200 - Boot:PP5022.mi4:e200\\nb\\n",
    "arm:build-sansae200:SanDisk Sansa e200 - Normal:rockbox.mi4:e200\\n\\n",
);

#********* Script code  ***********

# make this hash get the build string
# = 1 on start of build
# = 2 when the build has completed
# = 3 when all is done
my %work : shared;

# with the same key as above, we set the server name for the build
my %workby : shared;

# same key as above, we set the time stamp when work started, ie
# when it when into state 1
my %workstart : shared;

# same key as above, we set the "arch" for this build:
# sdl,arm,mm68k,sh
my %workarch : shared;

# same key as above, number of concurrent servers that builds this
my %worknum : shared;

my $now; # set to time at the start of a build round

sub filesize {
    my ($f)=@_;
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
        $atime,$mtime,$ctime,$blksize,$blocks)
        = stat($f);
    return $size;
}

sub logmsg {
    my $t = time()-$now; # number of seconds it has taken so far
    for(@_) {
        print "$t $_";
    }
}

# the amount of builds left
my $buildsleft : shared;
# set the amount of builds left:
$buildsleft = @builds;

my @dirs=("apps",
          "firmware",
          "gdb",
          "tools",
          "uisimulator",
          "bootloader");

my $dirs = join(" ", @dirs);

# use this time for all time stamps so that they remain the same all over
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
    gmtime(time);

# use this as machine datestring.
my $date = sprintf("%04d%02d%02dT%02d%02d%02dZ",
		   $year+1900, $mon+1, $mday, $hour, $min, $sec);

# date for humans
my $builddate=sprintf("%04d-%02d-%02d %02d:%02d:%02d",
		      $year+1900, $mon+1, $mday, $hour, $min, $sec);
# the SVN revisions from .. to, which an update involves
my $fromrev;
my $torev;

sub getentries {
    my @entries;

    @entries = `svnversion`;

    return @entries;
}

sub checkdiff {
    my $pwd =`pwd`;
    chomp $pwd;
    chdir $src;

    my @before = getentries();

    $fromrev = $before[0];
    chomp $fromrev;

    my $diff = `svn up | ./tools/svnupcheck.pl`;

    `svn up >/dev/null 2>&1`;

    my @after = getentries();

    $torev = $after[0];
    chomp $torev;

    chdir $pwd; # change back
    
    return $diff;
}


# sub to build on some server
sub buildremote {
    my ($date, $buildline, $server, $port, $arch) = @_;
    my $exitcode;
    my $fail;
    my $ssh_port;
    my $scp_port;
    my $wnum; # 0 for the first

    if($port) {
        $ssh_port = "-p $port";
        $scp_port = "-P $port";
    }
    {
	lock(%worknum);
	$wnum = $worknum{$buildline}++;
	if($wnum) {
	    # this is not the first server to do this build!
	    logmsg "non-primary build!\n";
	}
	else {
	    lock(%work);
	    $work{$buildline}=1; # work has begun!
	    lock(%workby);
	    $workby{$buildline}=$server; # this build is made by this server
	    lock(%workstart);
	    $workstart{$buildline}=time(); # starts now!
	    lock(%workarch);
	    $workarch{$buildline}=$arch; # starts now!
	}
    }

    # DEBUG:
    # logmsg "DBG: remote build of \"$buildline\" on \"$server\"\n";

    # Start the build. (use print to show client messages)
    `ssh -i privkey $ssh_port $sshopts $server "./acbuild.pl \\"$date\\" \\"$buildline\\" > /dev/null 2>&1" >>"output/stderr-$date" 2>&1`;
    $exitcode = $?;

    {
	lock(%work);
	my $w=$work{$buildline};
	if($wnum) {
	    # this is the secondary build 
	    if($w < 2) {
		# this primary one is still in 1 then we can tell it to stop!
		$work{$buildline}=4;
	    }
	    else {
		# the primary one has completed the build and is now
		# transferring, we thus stop here
		logmsg "The primary server completed the build before me ($server)\n";
		return 2;
	    }
	} 
	elsif($w > 1) {
	    # a secondary build outrun us, stop here
	    logmsg "A secondary server has taken over my ($server) build\n";
	    return 2;
	} 

	$work{$buildline}=2; # build done, now for the post stuff
    }

    # 2006-03-25 TS: exit code 1 = SSH trouble.
    if ($exitcode) {
        logmsg "Warning: $server failed with ssh exit code: $exitcode.\n";
        logmsg "attempt to get log to see *actual* fail reason\n";
        return 2;
	# $fail = 1; # this previously tried to check how far we had got
    }

    # Get the build info
    $buildline =~ /([^:]*):([^:]*):([^:]*):(.*)/;
    my ($dir, $desc, $target, $config)=($1,$2,$3,$4);
   
    logmsg "Copying $server:masterlog-$dir\n";
    `scp -C -i privkey $scp_port $sshopts $server:masterlog-$dir ./$dir/buildlog >>"output/stderr-$builddate" 2>&1`;
    $exitcode = $?;

    if($exitcode) {
        # true SSH failure
        logmsg "Failed getting the build log for $server/$dir, retry this\n";
        return 2;
    }
    elsif($fail) {
        # we got a failure returned from the build command line so we better
        # check how far we got in the build by checking the log we just copied
        # from the remote server
        if(!open(LOG, "<$dir/build.log")) {
            logmsg "Failed to open build log for $server/$dir, retry this\n";
            return 2;
        }
        my $end=0;
        while(<LOG>) {
            if(/^Build End/) {
                # jepps, it reached the end so we have a fine build!
                $end=1;
                logmsg("build log still indicates $server/$dir built to the end\n");
                last;
            }
        }
        close(LOG);
        if(!$end) {
            # the log we got was not a complete build, so we return 2 to
            # signal our parent that another server should better do this
            # build!
            logmsg("build log indicates $server/$dir did NOT build to the end\n");
            logmsg("hand this build over to another server instead, retry this\n");
            return 2;
        }
    }

    if( $bleeding{$dir} ) {
        # only copy bleeding zips for what we offer as bleeding edge builds
	my $start = time();
        logmsg "Copying $server:$dir/rockbox.zip\n";
        `scp -i privkey $scp_port $sshopts $server:$dir/rockbox.zip ./$dir/rockbox.zip >>"output/stderr-$builddate" 2>&1`;
        $exitcode = $?;

        if ($exitcode) {
            logmsg "Warning: couldn't get zip from $server/$dir\n";
        }
	my $t = time()-$start; # number of seconds it has taken so far
	if($t < 1) {
	    $t = 1;
	}
	my $sz = filesize("./$dir/rockbox.zip");
	my $speed = sprintf("%d bytes/second", $sz/$t);
        logmsg "Copied $server:$dir/rockbox.zip in $t seconds, $speed\n";
    }

    # time to cleanup!
    `ssh -i privkey $ssh_port $sshopts $server "rm -rf $dir masterlog-$dir" 2>&1`;
    $exitcode = $?;

    if($exitcode) {
	logmsg "Failed to do post-build cleanup on $server!\n";
    }
    else {
	logmsg "Remove $dir and masterlog-$dir from $server!\n";
    }

    {
	lock(%work);
	$work{$buildline}=3; # build complete
    }

    # DEBUG:
    logmsg "$dir ($desc) by $server done.\n";

    return 0;
}

# the function running a server build thread
sub server {
    # Get servername and targets.
    $_ =~ /([^:]*):(.*)/;
    my ($server, $targets) = ($1,$2);
    my $dobuild = "dummy";
    my $original;
    my $ssh_port;
    my $port;

    if($server =~ s/\/(\d+)//) {
        $port = $1;
        $ssh_port = "-p $port";
    }

    # repo update.
    `ssh -i privkey $ssh_port $sshopts $server "svn up -r $torev"`;

    # check if that update command was sent right.
    if ($? != 0) {
        # and if it wasn't, stop this server from building anything.
        logmsg "Warning: SSH+svn with server $server failed.\n";
        return $server;
    } else {
        logmsg "Ok: Server $server.\n";
    } 

    # get my targets in an array.
    @mytargets = split(/:/, $targets);

    # lable to jump to when not all builds are done.
    REBUILD:

    # try to build for each target.
    for my $target (@mytargets) {
        # DEBUG:
        # logmsg "    $server looking for $target\n";
        my $buildline;
        my $buildtarget;

        for my $build (@builds) {
            $dobuild = "";
            # open a block for the locks
            {
                lock(@builds);
 
                $build =~ /([^:]*):(.*)/;
                $buildline = $2;

                $buildtarget = $1;

                if ($target eq $buildtarget) {
		    # this build is for a target this server can build!
                    $dobuild = $buildline;
                    $build = sprintf "%s:%s",$server,$buildline;
                };
            } # unlocking builds and buildsleft here.
            if ($dobuild) {
                # DEBUG:
                logmsg "Server $server building: $dobuild\n";
                # do the building.
		my $err=buildremote($date, $dobuild, $server, $port, $target);
                if ($err == 2) {
                    lock(@builds);
                    lock($buildsleft);
                    $build = sprintf "%s:%s",$buildtarget,$buildline;
		    # Fix by Linus 2006-09-26
		    # Don't increase $buildsleft, since it is already correct
                    #$buildsleft++;
                } else {
                    lock($buildsleft);
                    $buildsleft--;
                }
            }
        }
    }

    # if not all targets are done, wait a while and try again.
    # BUG WARNING: Might not be threadsafe... 
    if($buildsleft > 0) {
        logmsg "Server $server finished, but $buildsleft builds left:\n";
	my $bestpick; # get out of the locks before building
	{
	    lock(%work);
	    lock(%worknum);
	    lock(%workby);
	    lock(%workstart);
	    lock(%workarch);
	    my $bestsince=9999;
	    my $c=1;
	    for my $wo (keys %work) {
		if($work{$wo} != 3) {
		    my $s = $workby{$wo};
		    my $v = $work{$wo};
		    my $since = time() - $workstart{$wo};
		    my $a = $workarch{$wo};
		    my $wnum = $worknum{$wo};
		    logmsg "- $c ($a) $wo on $s in $v since $since worknum $wnum\n";
		    for my $myt (@mytargets) {
			if(($myt eq $a) &&
			   ($v == 1) &&
			   ($wnum < 2) &&
			   ($since < $bestsince)) {
			    $bestsince = $since;
			    $bestpick=$c;
			}
		    }
		    $c++;
		}
	    }
	    if($bestpick) {
		logmsg "--- Would have picked $bestpick for $server\n";
	    }
	    else {
		my $t = join(", ", @mytargets); 
		logmsg "--- None matched (my targets: $t)\n";
	    }
	}
        sleep(5); 
        goto REBUILD;
    } 

    # DEBUG:
    logmsg "Server $server done (left=$buildsleft).\n";
    lock(%zipfile);
    $zipfile{$server}="die";
    return $server;
}

sub build {
    my $total=$buildsleft;
    my $file = sprintf "%04d%02d%02d", $year+1900, $mon+1, $mday;
    my @thrs;
    my $server;
    my $dir;

    # Clean up the builddirs.
    for(@builds) {
        $_ =~ /([^:]*):([^:]*):([^:]*):([^:]*):(.*)/;
        $dir=$2;
        `rm -Rf $dir`;
        `mkdir $dir`;
    }

    # empty the source dir too
    `rm build-source/*`; 

    open(DEST, ">>output/allbuilds-$file");

    print DEST "Build Start All Systems\n";

    # get all servers working.
    for (@servers) {
        push @thrs, threads->new(\&server, $_); # build thread
    }

    # DEBUG:
    # print " Threads started, waiting...\n";
   
    # Wait for all threads to finish.
    foreach (@thrs) {
        $_->join();
    }

    # DEBUG:
    # print " All threads done, total: $total left: $buildsleft\n";
    if ($buildsleft != 0) {
        logmsg "Warning: We have $buildsleft builds not done because there was no server availible.\n";
    }

    # Now we should create a combined buildlog for all other scripts.
    for(@builds) {
        $_ =~ /([^:]*):([^:]*):([^:]*):([^:]*):(.*)/;
        ($server, $dir)=($1,$2);
        print DEST "Build Server: $server\n";
        open(LOG, "<$dir/buildlog");
        while(<LOG>) {
            print DEST "$_";
        }
        close(LOG);
    }

    print DEST "Build End All Systems\n";

    close(DEST);
}

if($ARGV[0] eq "sizes") {
    foreach my $b (@builds) {
        my ($arch, $dir, $text, $binary, $keys)=split(":", $b);
	if($bleeding{$dir}) {
	    my $target = $dir;
	    my $bytes;
	    if(-f "$dir/rockbox.zip") {
		# unzip -p build-sansae200/rockbox.zip .rockbox/rockbox-info.txt
		open(Z, "unzip -p $dir/rockbox.zip .rockbox/rockbox-info.txt|");
		while(<Z>) {
		    if(/^Actual size: (\d+)/i) {
			$bytes = $1;
			last;
		    } 
		}
		close(Z);

		#if($binary !~ /(mod|ajz|wma)\z/i) {
		#    $binary = ".rockbox/".$binary;
		#}

		#my @sz=`unzip -l $dir/rockbox.zip $binary | tail -n 1`;
		#$bytes = int($sz[0]);
	    }
	    else {
		# no file, count as zero bytes
		$bytes=0;
	    }

	    $target =~ s/build-//g;
	    printf("%-13s: %6d  - $binary $arch\n", $target, $bytes);
	}
    }
    exit;
}

if($ARGV[0] eq "pix") {
    my $b;
    foreach $b (@builds) {
        my ($arch, $dir, $text, $binary, $keys)=split(":", $b);
        print "long: $text => ";

        $text =~ s/FM Recorder/FM/;
        $text =~ s/Playerold/P-old/;
        $text =~ s/Player/Play/;
        $text =~ s/Recorder/Rec/;
        $text =~ s/Debug/Dbg/;
        $text =~ s/Normal//;
        $text =~ s/Simulator/Sim/;
        $text =~ s/iriver *//i;
        $text =~ s/Archos *//i;
        $text =~ s/ - $//;
        $text =~ s/Win32/Win/;
        $text =~ s/- +-/-/g;
        $text =~ s/Grayscale/Gray/;
        $text =~ s/Sim - Win/Sim32/;
        $text =~ s/Toshiba *//i;
        $text =~ s/SanDisk *//i;

        print "short: $text\n";

        # create image with text
        # -border 1x1 -bordercolor "#000000"
        `convert -font helvetica -pointsize 13 -fill black -draw "text 1,13 '$text'" input-bg2.png dump.png`;
        # rotate image
        `convert -rotate -90 dump.png $dir.png`;
    }
    exit;
}

sub nicehead {
    my ($file, $date)=@_;

    open(NICE, ">$file");
    open(READ, "<head.html");
    while(<READ>) {
        s/_PAGE_/Build $date/;
        print NICE $_;
    }

    print NICE <<MOO

<p>These are the most recent changes included in the build $date:

<p>
MOO
;

    close(NICE);
    close(READ);

}

sub nicefoot {
    my ($file, $date)=@_;

    open(NICE, ">>$file");
    open(READ, "<foot.html");

    print NICE <<MOO
<p>
 Back to <a href="http://www.rockbox.org/daily.shtml">daily builds</a> / <a href="http://build.rockbox.org/">SVN builds</a>
MOO
;
    while(<READ>) {
        s/_PAGE_/$date/;
        print NICE $_;
    }
    close(NICE);
    close(READ);
}

my $difference;

my $pidfile="master_pid";

if(!$ARGV[0]) {
    if( -f $pidfile) {
        # if the're a dangling pid file, we count that as a forced "diff" 
        # and rerun the lot!
        $difference = 1;
	checkdiff();
    }
    else {
        $difference=checkdiff();
    }
}
else {
    $difference = 1; # force
}

if(!$torev) {
    # we don't know, figure it out
    my $pwd =`pwd`;
    chomp $pwd;
    chdir $src;
    my @all=`svnversion`;
    $torev = $all[0];
    chomp $torev;
    chdir $pwd;
}

# DEBUG:

if($difference) {
    $now = time();
    open(PIDFILE, ">$pidfile");
    print PIDFILE "$$\n";
    close(PIDFILE);
    
    logmsg "repo update done, diff detected. Started: $builddate\n";

    # figure out previous build time!
    open(BUILDTIME, "<output/build-info");
    my $prev;
    while(<BUILDTIME>) {
        if ($_ =~ /^timestamp = \"([^\"]+)\"/) {
            $prev="$1";
        }
    }
    close(BUILDTIME);

    # get a log between previous situation and the current
    my $f = sprintf("%d", $fromrev+1);
    system("./lastperiodcvs.pl $src $f $torev > floink");

    nicehead("output/chlog-$date.html",
	     "$builddate - from r$fromrev to r$torev");
    `/home/dast/svnlog2html.pl < floink >> "output/chlog-$date.html"`;
    nicefoot("output/chlog-$date.html", $builddate);

    # DEBUG:
    logmsg "Creating temp. buildpage.\n";

    system("./showbuilds.pl \"cvsmod/chlog-$date.html\" > output/index-2.html");
    system("mv output/index-2.html output/index.html");

    # DEBUG:
    logmsg "Building now...\n";

    build();
    logmsg "buildtime = ", time - $now, "\n";
    open(IN, "<output/build-time");
    my $prevtime = <IN>;
    close(IN);

    logmsg("mv dbglog \"output/dbg-$date.log\"\n");
    system("mv dbglog \"output/dbg-$date.log\"");

    # cut off a 1/4 of the old value, add a 1/4 of the new value
    $prevtime -= $prevtime/4;
    $tooktime = time()-$now; # number of seconds it took

    $prevtime += $tooktime/4;

    open(OUT, ">output/build-time");
    printf OUT "%d\n", $prevtime;
    close(OUT);
    # store the exact time of latest build
    open(OUT, ">output/last-build-time");
    printf OUT "%d\n", $tooktime;
    close(OUT);
    unlink("floink");

    logmsg("create build table\n");
    system("./showbuilds.pl > output/index-2.html");
    system("mv output/index-2.html output/index.html");

    # build source package
    logmsg("build source package\n");
    system("./mksource $src");

    open(BUILDTIME, ">output/build-info");
    print BUILDTIME "[bleeding]\n";
    print BUILDTIME "timestamp = \"$date\"\n";
    close(BUILDTIME);

    logmsg("extract binary sizes\n");
    system("./buildmaster.pl sizes > output/sizes-$date");

    logmsg("build delta table\n");
    system("./showsize.pl > output/sizes.html");

    logmsg "all done.\n";

    unlink($pidfile);
}