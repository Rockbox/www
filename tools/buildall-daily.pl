#!/usr/bin/perl

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
 localtime(time);

$mon+=1;
$year+=1900;

$date=sprintf("%04d%02d%02d", $year,$mon, $mday);
$shortdate=sprintf("%02d%02d%02d", $year%100,$mon, $mday);

$ENV{'PATH'}.=":/usr/local/sh-gcc/bin:/usr/local/m68k-gcc/bin:/usr/local/arm-elf/bin";

my $verbose;
if($ARGV[0] eq "-v") {
    $verbose =1;
    shift @ARGV;
}

my $doonly;
if($ARGV[0]) {
    $doonly = $ARGV[0];
    print "only build $doonly\n" if($verbose);
}

# made once for all targets
sub runone {
    my ($dir, $confnum, $extra)=@_;
    my $a;

    if($doonly && ($doonly ne $dir)) {
        return;
    }

    mkdir "build-$dir";
    chdir "build-$dir";
    print "Build in build-$dir\n" if($verbose);

    # build the manual(s)
    $a = buildit($dir, $confnum, $extra);

    chdir "..";

    my $o="build-$dir/rockbox.zip";
    if (-f $o) {
        my $newo="output/$dir/rockbox-$dir-$date.zip";
        system("mkdir -p output/$dir");
        # update the most recent file
        system("cp $o output/$dir/rockbox-$dir.zip");
        system("mv $o $newo");
        print "moved $o to $newo\n" if($verbose);
    }

    print "remove all contents in build-$dir\n" if($verbose);
    system("rm -rf build-$dir");

    return $a;
};

sub fonts {
    my ($dir, $confnum, $newl)=@_;
    my $a;

    if($doonly && ($doonly ne $dir)) {
        return;
    }

    mkdir "build-$dir";
    chdir "build-$dir";
    print "Build fonts in build-$dir\n" if($verbose);

    # build the manual(s)
    $a = buildfonts($dir, $confnum, $newl);

    chdir "..";

    my $o="build-$dir/rockbox-fonts.zip";
    if (-f $o) {
        my $newo="output/fonts/rockbox-fonts-$date.zip";
        system("mkdir -p output/fonts");
        # update the most recent file
        system("cp $o output/fonts/rockbox-fonts.zip");
        system("mv $o $newo");
        print "moved $o to $newo\n" if($verbose);
    }

    print "remove all contents in build-$dir\n" if($verbose);
    system("rm -rf build-$dir");

    return $a;
};



sub buildit {
    my ($target, $confnum, $extra)=@_;

    `rm -rf * >/dev/null 2>&1`;

    my $c = sprintf('echo -e "%s\n%sn\n" | ../tools/configure',
                    $confnum, $extra);

    print "C: $c\n" if($verbose);
    `$c`;

    print "Run 'make'\n" if($verbose);
    `make 2>/dev/null`;

    print "Run 'make zip'\n" if($verbose);
    `make zip 2>/dev/null`;
}

sub buildfonts {
    my ($target, $confnum, $newl)=@_;

    `rm -rf * >/dev/null 2>&1`;

    my $c = sprintf('echo -e "%s\n%sn\n" | ../tools/configure',
                    $confnum, $newl?'\n':'');

    print "C: $c\n" if($verbose);
    `$c`;

    print "Run 'make fontzip'\n" if($verbose);
    `make fontzip 2>/dev/null`;
}

sub source {
    if($doonly && ($doonly ne "source")) {
        return;
    }
    print "./tools/release $date\n" if($verbose);

    `./tools/release $date`;

    my $o="rockbox-$date.tar.bz2";
    if (-f $o) {
        my $newo="output/source/rockbox-$date.tar.bz2";
        system("mkdir -p output/source");
        # update the most recent file
        system("cp $o output/source/rockbox.tar.bz2");
        system("mv $o $newo");
        print "moved $o to $newo\n" if($verbose);
    }
    print "source build done\n" if($verbose);
}

sub dailylog {
    if ($doonly) {
        return;
    }
    `./dailychanges.sh "$date 06:00"`;
}

sub buildinfo {
    if($doonly) {
        return;
    }
    open(F, ">output/build-info");
    print F "[dailies]\ndate = \"$date\"\n";
    close(F);
}

# we get the changes first to get them properly at this time as exact
# as possible
dailylog();

# run make in tools first to make sure they're up-to-date
print "cd tools && make\n" if($verbose);
`(cd tools && make ) >/dev/null 2>&1`;

runone("player", "player", '\n');
runone("recorder", "recorder", '\n');
runone("recorder8mb", "recorder", '8\n');
runone("fmrecorder", "fmrecorder", '\n');
runone("fmrecorder8mb", "fmrecorder", '8\n');
runone("recorderv2", "recorderv2", '\n');
runone("ondiosp", "ondiosp", '\n');
runone("ondiofm", "ondiofm", '\n');
runone("h100", "h100");
runone("h120", "h120");
runone("h300", "h300");
runone("ipodcolor", "ipodcolor");
runone("ipodnano", "ipodnano");
runone("ipod4gray", "ipod4g");
runone("ipodvideo", "ipodvideo", '32\n');
runone("ipodvideo64mb", "ipodvideo", '64\n');
runone("ipod3g", "ipod3g");
runone("iaudiox5", "x5");
runone("iaudiom5", "m5");
runone("ipodmini1g", "ipodmini");
runone("ipodmini2g", "ipodmini2g");
runone("h10", "h10");
runone("h10_5gb", "h10_5gb");
runone("gigabeatf", "gigabeatf");
runone("sansae200", "e200");
fonts("fonts", "x5");
source();
buildinfo();
