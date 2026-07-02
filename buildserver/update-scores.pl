#!/usr/bin/perl
#
# This script walks through the 'builds' file, building each one in turn
# and updating the 'scores' value.
#
# As the scores are only relevant relative to each other, it is important that
# all scores are generated using the same build system, using a warm filesystem cache,
# and are periodically regenerated, especially in the face of new/updated toolchains.
#

my $rbdir = "..";

my $jobs = `nproc` + 0;

while (<STDIN>) {
    if (/^\#/) {
        print;
        next;
    }
    chomp;
    my @row = split(/:/);

    my $make = $row[3];
    my $oldscore = $row[6];
    my $build = $row[7];

    if ($build =~ s/%SRCDIR%/$rbdir/) {

    } else {
        $build = $rbdir . '/' . $build;
    }

    my @tmp = split(/&&/,$build);
    $ENV{'CCACHE_DISABLE'} = "true";

    my $conf = $tmp[0];

    $build = $tmp[1]. " -j$jobs ";

    $build =~ s/make zip/make/;  # Leave out the zip

    system("$conf > /dev/null");
    system("make clean > /dev/null");
    my $score = `(/usr/bin/time -f"%U+%S" -o /tmp/buildtime $build >/dev/null 2>&1) && bc -l < /tmp/buildtime` * 100;
    system("make clean > /dev/null");

    $row[6] = $score;

    my $newrow = join(':',@row);
    print "$newrow\n";
}
