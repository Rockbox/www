#!/usr/bin/perl

my $cwd = `pwd`;
chomp $cwd;

# look up last 25 commits
chdir "/home/rockbox/rockbox_git_clone";
my @lines = `git log --oneline -25`;

my %hash = ('rockbox' => 1); # leave files called "rockbox-*" (binaries)

for (@lines) {
    if (/^(\w+) /) {
	$foo = substr($1, 0, 7);  # Truncate to LCD
        $hash{$foo} = 1;
    }
}

# remove all files that are not in last 25
chdir "$cwd/data";
opendir(DIR, ".") || die "can't opendir .: $!";
my @files = readdir(DIR);
closedir DIR;

for my $f (@files) {
    if ($f =~ /^(\w+)/) {
	$foo = substr($1, 0, 7); # Truncate to LCD..
        if (not defined $hash{$foo}) {
            unlink $f or die "Failed to remove $f: $!";
        }
    }
}
