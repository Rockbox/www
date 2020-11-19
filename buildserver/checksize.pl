#!/usr/bin/perl
require './rbmaster.pm';

my $build = $ARGV[0];
my $zip = "data/rockbox-$build.zip";

db_connect();
my $sth = $db->prepare("UPDATE builds SET ramsize=?,binsize=? WHERE revision=? and id=?") or
    warn "DBI: Can't prepare statement: ". $db->errstr;

if (-f $zip) {
    if (open(Z, "unzip -p $zip .rockbox/rockbox-info.txt|")) {
        while(<Z>) {
            if(/^Actual size: (\d+)/i) {
                $bytes = $1;
            }
            elsif(/^RAM usage: (\d+)/i) {
                $ram = $1;
            }
            elsif(/^Version: *(\w+)-.*/i) {
                $shortrev = $1;
            }
        }
        close(Z);
        
        print "rev $shortrev build $build ramsize $ram bytes $bytes\n";

        $sth->execute($ram, $bytes, $shortrev, $build);
    }
}
