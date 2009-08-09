#!/usr/bin/perl

use DBI;
require 'rbmaster.pm';

&getbuilds("builds");

my $rev = $ARGV[0];

&db_connect();

my $num = 0;
my $sth = $db->prepare("SELECT id,client,timeused,ultime FROM builds WHERE revision=?");
my $rows = $sth->execute($rev) + 0;
if ($rows) {
    while (my ($id, $client, $time, $ultime) = $sth->fetchrow_array()) {
        $clients{$client}{$id} = $time - $ultime;
        $score{$client} += $builds{$id}{score};
        $num++;
    }
}

$sth = $db->prepare("SELECT name FROM clients WHERE lastrev=?");
$rows = $sth->execute($rev) + 0;
if ($rows) {
    while (my ($name) = $sth->fetchrow_array()) {
        push @clist, $name;
    }
}

&nicehead("Build client stats, revision $rev");

printf("<p>For these $num builds, the following %d build clients participated:\n",
       scalar @clist);

print "<table><tr><th>Client</th> <th>Score</th> <th>Avg speed<br>(pts/sec)</th> <th>Round<br>speed</th> <th>Builds</th> <th>Total time</th> <th>All times</th> </tr>\n";

for my $c (sort {$score{$b} <=> $score{$a}} @clist) {
    my ($speed, $ulspeed) = &getspeed($c);
    my $numbuilds = 0;
    my $times;
    my $total = 0;
    for my $id (keys %{$clients{$c}}) {
        my $t = $clients{$c}{$id};
        $total += $t;
        $times .= "<span title='$id'>$t</span> ";
        $numbuilds += 1;
    }
    my $roundspeed = 0;
    if ($total) {
        $roundspeed = int($score{$c} / $total);
        $totalspeed += $roundspeed;
    }
    else {
        $totalspeed += $speed;
    }
    my $sc = 0;
    $sc = $score{$c} if defined ($score{$c});
    print "<tr> <td>$c</td> <td>$sc</td> <td align=center>$speed</td> <td align=center>$roundspeed</td> <td align=center>$numbuilds</td> <td align=center>$total</td> <td>$times</td> </tr>\n";
}
print "</table>\n";

my $end = `tail -100 logfile | grep "End of round $rev"`;
if ($end =~ /seconds (\d+) wasted (\d+)/) {
    my ($timeused, $wasted) = ($1, $2);
    my $proc = int(100 * $wasted / ($timeused * scalar @clist));
    print "<p>This build round took $timeused seconds. $wasted cpu seconds ($proc%) were spent on cancelled builds.\n";

    for (@buildids) {
        $totalwork += $builds{$_}{score};
    }

    $ourspeed = int($totalwork / $timeused);
    printf("<br>Total client speed was $totalspeed points/second, which in ideal conditions would complete the round in %d seconds.\n", 
           $totalwork / $totalspeed);
    printf("<br>Effective round speed was $ourspeed points/second, making us %d%% efficient.\n",
           $ourspeed * 100 / $totalspeed);
          
}

&nicefoot();
