#!/usr/bin/perl

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
 localtime(time);

$mon+=1;
$year+=1900;

$date=sprintf("%04d%02d%02d", $year,$mon, $mday);
$shortdate=sprintf("%02d%02d%02d", $year%100,$mon, $mday);

$ENV{'PATH'}.=":/usr/local/sh-gcc/bin:/usr/local/m68k-gcc/bin:/usr/local/arm-gcc/bin";

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
    my ($dir, $conf, $nl)=@_;
    my $a;

    if($doonly && ($doonly ne $dir)) {
        return;
    }

    mkdir "build-$dir";
    chdir "build-$dir";
    print "Build in build-$dir\n" if($verbose);

    # build the manual(s)
    $a = buildit($dir, $conf, $nl);

    chdir "..";

    my $o="build-$dir/manual/rockbox-build.pdf";
    if (-f $o) {
        my $newo="output/rockbox-$dir-$date.pdf";
        system("cp $o output/rockbox-$dir.pdf");
        system("mv $o $newo");
        print "moved $o to $newo\n" if($verbose);
    }

    $o="build-$dir/rockbox-manual.zip";
    if (-f $o) {
        my $newo="output/rockbox-$dir-$date-html.zip";
        system("cp $o output/rockbox-$dir-html.zip");
        system("mv $o $newo");
        print "moved $o to $newo\n" if($verbose);
    }

    $o="build-$dir/html";
    if (-d $o) {
        my $newo="output/rockbox-$dir";
        system("rm -rf $newo");
        system("cp -r $o $newo");
        print "copied $o to $newo\n" if($verbose);
    }

    print "remove all contents in build-$dir\n" if($verbose);
    system("rm -rf build-$dir");

    return $a;
};

sub buildit {
    my ($target, $confnum, $newl)=@_;

    `rm -rf * >/dev/null 2>&1`;

    my $c = sprintf('echo -e "%s\n%sm\n" | ../tools/configure',
                    $confnum, $newl?'\n':'');

    print "C: $c\n" if($verbose);
    `$c`;

    print "Run 'make'\n" if($verbose);
    `make 2>/dev/null`;

    print "Run 'make manual-zip'\n" if($verbose);
    `make manual-zip 2>/dev/null`;
}

# run make in tools first to make sure they're up-to-date
`(cd tools && make ) >/dev/null 2>&1`;

runone("player", "player", 1);
runone("recorder", "recorder", 1);
runone("fmrecorder", "fmrecorder", 1);
runone("recorderv2", "recorderv2", 1);
runone("ondiosp", "ondiosp", 1);
runone("ondiofm", "ondiofm", 1);
runone("h100", "h100");
#runone("h120", 9);
runone("h300", "h300");
runone("ipodcolor", "ipodcolor");
runone("ipodnano", "ipodnano");
runone("ipod4gray", "ipod4g");
runone("ipodvideo", "ipodvideo");
runone("ipod3g", "ipod3g");
runone("iaudiox5", "x5");
runone("iaudiom5", "m5");
runone("ipodmini2g", "ipodmini2g");
runone("h10", "h10");
runone("h10_5gb", "h10_5gb");
runone("gigabeatf", "gigabeatf");
runone("sansae200", "e200");
