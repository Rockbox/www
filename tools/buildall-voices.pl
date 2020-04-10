#!/usr/bin/perl

require "./rockbox.pm";

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
 localtime(time);

$mon+=1;
$year+=1900;

$date=sprintf("%04d%02d%02d", $year,$mon, $mday);
$shortdate=sprintf("%02d%02d%02d", $year%100,$mon, $mday);

# 'lame' assumed to be on system path already!

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
    my ($dir)=@_;
    my $a;

    if($doonly && ($doonly ne $dir)) {
        return;
    }

    mkdir "build-$dir";
    chdir "build-$dir";
    print "Build in build-$dir\n" if($verbose);

    # build the manual(s)
    $a = buildit($dir);

    chdir "..";

    my $o="build-$dir/english.voice";
    if (-f $o) {
        my $newo="output/$dir-$date-english.zip";
        system("cp $o output/$dir-$date-english.voice");
        system("mkdir -p .rockbox/langs");
        system("cp $o .rockbox/langs");
        system("zip -q -r $newo .rockbox");
        system("rm -rf .rockbox");
        `chmod a+r $newo`;
        print "moved $o to $newo\n" if($verbose);
    }

    print "remove all contents in build-$dir\n" if($verbose);
    system("rm -rf build-$dir");

    return $a;
};

sub buildit {
    my ($dir)=@_;

    `rm -rf * >/dev/null 2>&1`;

    my $c = "../../rockbox_git_clone/tools/configure --no-ccache --type=av --target=$dir --ram=-1 --language=0 --tts=f --voice=-1";

    print "C: $c\n" if($verbose);
    system($c);

    print "Run 'make voice'\n" if($verbose);
    `make voice`;
}

sub buildinfo {
    if($doonly) {
       return;
    }

    # store info for the latest build
    open(F, ">output/build-info");
    print F "[voices]\ndate = \"$date\"\nrev = $rev\n";
    close(F);
    
    # store info for this particular date
    open(F, ">output/build-info-$date");
    print F "[voices]\ndate = \"$date\"\nrev = $rev\n";
    close(F);
}

# run make in tools first to make sure they're up-to-date
`(cd tools && make ) >/dev/null 2>&1`;

`rm -f /home/rockbox/dailybuild-voices/voice-pool/*`;
$ENV{'POOL'}="/home/rockbox/dailybuild-voices/voice-pool";

for my $b (&usablebuilds) {
    next if ($builds{$b}{voice}); # no variants

    runone($b);
}

`rm -f /home/rockbox/dailybuild-voices/voice-pool/*`;
