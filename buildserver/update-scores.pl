#!/usr/bin/perl
#
# This script walks through the 'builds' file, building each one in turn
# and updating the 'scores' value.
#
# As the scores are only relevant relative to each other, it is important that
# all scores are generated using the same build system, using a warm filesystem cache,
# and are periodically regenerated, especially in the face of new/updated toolchains.
#

my $jobs = `nproc` + 0;

while (<STDIN>) {
    if (/^\#/) {
        print;
        next;
    }
    chomp;
    my @row = split(/:/);

    my $make = $row[2];
    my $oldscore = $row[5];
    my $build = $row[6];

    my @tmp = split(/&&/,$build);
    my $conf = $tmp[0] . " --no-ccache ";

    $build = $tmp[2] . " -j$jobs ";

    $build =~ s/make zip/make/;  # Leave out the zip

    system("$conf > /dev/null");
    system("make clean > /dev/null");
    my $score = `(/usr/bin/time -f"%U+%S" $build >/dev/null) 2>&1 | bc -l` * 100;
    system("make clean > /dev/null");

    $row[5] = $score;

    my $newrow = join(':',@row);
    print "$newrow\n";
}
