#!/usr/bin/perl

use File::Basename;
use Cwd;

my $datadir = getcwd() . "/data";

-d $ENV{'ROCKBOX_GIT_DIR'} || die ("Can't find ROCKBOX_GIT_DIR");

# look up last 25 commits
my @lines = `git --git-dir=$ENV{'ROCKBOX_GIT_DIR'}/.git log --oneline -25`;

# Ignore some files
my %hash = ('rockbox' => 1); # leave files called "rockbox-*" (binaries)

for (@lines) {
    if (/^(\w+) /) {
	$foo = substr($1, 0, 10);  # Truncate to LCD
        $hash{$foo} = 1;
    }
}

# remove all files that are not in last 25 commits
opendir(DIR, $datadir) || die "can't opendir '$datadir': $!";
my @files = readdir(DIR);
closedir DIR;

for my $f (@files) {
    my $f2 = basename($f);
    if ($f2 =~ /^(\w+)/) {
	$foo = substr($1, 0, 10); # Truncate to LCD..
        if (not defined $hash{$foo}) {
#	    print "removing $f\n";
            unlink "$datadir/$f" or die "Failed to remove $datadir/$f: $!";
        } else {
#	    print "skipping $f\n";
	}
    }
}
