#!/usr/bin/perl
require './rbmaster.pm';

sub getspeeds($)
{
    db_connect() if (not $db);

    my ($cli) = @_;
    my $maxrows = 10;

    my $getspeed_sth = $db->prepare("SELECT id, timeused, ultime, ulsize FROM builds WHERE client=? AND errors = 0 AND warnings = 0 AND timeused > 0 ORDER BY time DESC LIMIT ?") or
        warn "DBI: Can't prepare statement: ". $db->errstr;

    my $rows = $getspeed_sth->execute($cli, $maxrows);
    if ($rows > 0) {
        my @ulspeeds;
        my @buildspeeds;

        # fetch score for $avgcount latest revisions (build rounds)
        while (my ($id, $buildtime, $ultime, $ulsize) = $getspeed_sth->fetchrow_array()) {
            my $points = $builds{$id}{score};
            my $arch = $builds{$id}{arch};
            push @buildspeeds, int($points / $buildtime) . " $id";

            if ($ulsize && $ultime) {
                push @ulspeeds, int($ulsize / $ultime);
            }

        }
        $getspeed_sth->finish();

        print "buildspeeds: ", join(" ", sort {$a <=> $b} @buildspeeds), "\n";

        # take the "33% median" speed
        my $bs = (sort {$a <=> $b} @buildspeeds)[scalar @buildspeeds / 2];
        my $us = (sort {$a <=> $b} @ulspeeds)[scalar @ulspeeds / 2];
        
        return ($bs, $us);
    }
    return (0, 0);
}

getbuilds();
db_connect();

my $client = shift @ARGV;

my ($bs, $us) = getspeeds($client);
print "build: $bs upload: $us\n";
