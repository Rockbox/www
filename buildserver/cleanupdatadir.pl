#!/usr/bin/perl

my $cwd = `pwd`;
chomp $cwd;

# look up last 30 commits
chdir "/sites/rockbox.org/trunk";
my @lines = `git log --oneline -30`;

my %hash = ('rockbox' => 1); # leave files called "rockbox-*" (binaries)

for (@lines) {
    if (/^(\w+) /) {
        $hash{$1} = 1;
    }
}

# remove all files that are not in last 20
chdir "$cwd/data";
opendir(DIR, ".") || die "can't opendir .: $!";
my @files = readdir(DIR);
closedir DIR;

for my $f (@files) {
    if ($f =~ /^(\w+)-/) {
        if (not defined $hash{$1}) {
            unlink $f or die "Failed to remove $f: $!";
        }
    }
}
