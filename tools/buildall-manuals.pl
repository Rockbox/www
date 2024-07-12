#!/usr/bin/perl
use Cwd;

require "./rockbox.pm";

my $source_dir = $ENV{'ROCKBOX_GIT_DIR'};

my $cwd = getcwd();

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
 localtime(time);

$mon+=1;
$year+=1900;

$date=sprintf("%04d%02d%02d", $year,$mon, $mday);
$shortdate=sprintf("%02d%02d%02d", $year%100,$mon, $mday);

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

    my $now = time;

    mkdir "build-$dir";
    chdir "build-$dir";
    if (open(NOBACKUP, ">.nobackup")) {
        close NOBACKUP;
    }
    print "Build in build-$dir\n" if($verbose);

    # build the manual(s)
    $a = buildit($dir);

    chdir $cwd;

    my $o="build-$dir/rockbox-manual.pdf";
    if (-f $o) {
        my $newo="output/rockbox-$dir-$date.pdf";
        system("cp $o output/rockbox-$dir.pdf");
        system("mv $o $newo");
        `chmod a+r $newo`;
        print "moved $o to $newo\n" if($verbose);
        system("cd ../download/daily/$dir ; ln -sf ../manual/rockbox-$dir.pdf manual-$dir.pdf");
    }
    else  {
        print "*** error: no pdf file $o\n" if($verbose);
    }

    $o="build-$dir/rockbox-manual.zip";
    if (-f $o) {
        my $newo="output/rockbox-$dir-$date-html.zip";
        system("cp $o output/rockbox-$dir-html.zip");
        system("mv $o $newo");
        print "moved $o to $newo\n" if($verbose);
        system("cd ../download/daily/$dir ; ln -sf ../manual/rockbox-$dir-html.zip manual-$dir-html.zip");
    }
    else  {
        print "*** error: no zip file $o\n" if($verbose);
    }

    $o="build-$dir/html";
    if (-d $o) {
        my $newo="output/rockbox-$dir";
        system("rm -rf $newo");
        system("cp -r $o $newo");
        print "copied $o to $newo\n" if($verbose);
    }
    else  {
        print "*** error: no html dir $o\n" if($verbose);
    }

    print "remove all contents in build-$dir\n" if($verbose);
    system("rm -rf build-$dir");

    return $a;
};

sub buildit {
    my ($target)=@_;

    `rm -rf * >/dev/null 2>&1`;

    my $c = "$source_dir/tools/configure --target=$target --type=m --ram=-1";

    print "C: $c\n" if($verbose);
    system($c);

    print "Run 'make'\n" if($verbose);
    system("make manual");

    print "Run 'make manual-zip'\n" if($verbose);
    system("make manual-zip");
}

# run make in tools first to make sure they're up-to-date
`(cd $source_dir/tools && make ) >/dev/null 2>&1`;

for my $build (&usablebuilds) {
    my $name = manualname($build);
    next if (not -f "$source_dir/manual/platform/$name.tex");
    
    runone($name);
}
