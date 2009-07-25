#!/usr/bin/perl

use DBI;
require 'rbmaster.pm';

&getbuilds("builds");

my $rev = $ARGV[0];

&db_connect();

my $sth = $db->prepare("SELECT id,client,timeused,ultime FROM builds WHERE revision=?");
my $rows = $sth->execute($rev) + 0;
if ($rows) {
    while (my ($id, $client, $time, $ultime) = $sth->fetchrow_array()) {
        $clients{$client}{$id} = $time - $ultime;
        $score{$client} += $builds{$id}{score};
    }
}

&nicehead("Build client stats, revision $rev");

printf("<p>For these $rows builds, the following %d build clients participated:\n",
       scalar keys %clients);

print "<table><tr><th>Client</th> <th>Score</th> <th>Avg speed<br>(pts/sec)</th> <th>Round<br>speed</th> <th>Builds</th> <th>Total time</th> <th>All times</th> </tr>\n";

for my $c (sort {$score{$b} <=> $score{$a}} keys %clients) {
    my $speed = &getspeed($c);
    my $builds;
    my $times;
    my $total;
    for my $id (keys %{$clients{$c}}) {
        my $t = $clients{$c}{$id};
        $total += $t;
        $times .= "$t ";
        $builds += 1;
    }
    my $roundspeed = int($score{$c} / $total);
    print "<tr> <td>$c</td> <td>$score{$c}</td> <td align=center>$speed</td> <td align=center>$roundspeed</td> <td align=center>$builds</td> <td align=center>$total</td> <td>$times</td> </tr>\n";
}
print "</table>\n";

my $end = `tail -100 logfile | grep "End of round $rev"`;
if ($end =~ /seconds (\d+) wasted (\d+)/) {
    my $proc = int(100 * $2 / ($1 * scalar keys %clients));
    print "<p>This build round took $1 seconds. $2 cpu seconds ($proc%) were spent on cancelled builds.\n";
}

&nicefoot();
