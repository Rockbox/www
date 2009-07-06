#!/usr/bin/perl

my $build = $ARGV[0];
my $zip = "data/rockbox-$build.zip";

if (-f $zip) {
    if (open(Z, "unzip -p $zip .rockbox/rockbox-info.txt|")) {
        while(<Z>) {
            if(/^Actual size: (\d+)/i) {
                $bytes = $1;
            }
            elsif(/^RAM usage: (\d+)/i) {
                $ram = $1;
            }
            elsif(/^Version: *r(\d+)/i) {
                $rev = $1;
            }
        }
        close(Z);
        
        if (open(S, ">data/$rev-$build.size")) {
            printf S "$build: $bytes $ram\n";
            close S;
        }
    }
}
