#!/usr/bin/perl

use DBI;
require 'rbmaster.pm';

&getbuilds("builds");

my $rev = $ARGV[0];

$SIG{__DIE__} = sub { printf("Perl error: %s", @_); };

&db_connect();

my $num = 0;
my $sth = $db->prepare("SELECT id,client,timeused,ultime,ulsize FROM builds WHERE revision=?");
my $rows = $sth->execute($rev) + 0;
if ($rows) {
    while (my ($id, $client, $time, $ultime, $ulsize) = $sth->fetchrow_array()) {
        $client = lc $client;
        $clients{$client}{$id} = int($time + 0.5);
        $score{$client} += $builds{$id}{score};
        $num++;
        $ul{$client}{ultime} += $ultime;
        $ul{$client}{ulsize} += $ulsize;
    }
}

$sth = $db->prepare("SELECT name FROM clients WHERE lastrev=?");
$rows = $sth->execute($rev) + 0;
if ($rows) {
    while (my ($name) = $sth->fetchrow_array()) {
        push @clist, lc $name;
        $realname{lc $name} = $name;
    }
}

&nicehead("Build client stats, revision $rev");

printf("<p>For these $num builds, the following %d build clients participated:\n",
       scalar @clist);

print "<table><tr><th>Client</th> <th>Score</th> <th>Est speed<br>(pts/sec)</th> <th>Round<br>speed</th> <th>Avg UL<br>speed</th> <th>Round<br>UL speed</th> <th>Builds</th> <th>Total time</th> <th>All times</th> </tr>\n";

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
    my $roundulspeed = "-";
    if ($ul{$c}{ulsize} and $ul{$c}{ultime}) {
        $roundulspeed = int($ul{$c}{ulsize} / $ul{$c}{ultime} / 1024);
    }
    $ulspeed = int($ulspeed / 1024);
    print "<tr> <td>$realname{$c}</td> <td>$sc</td> <td align=center>$speed</td> <td align=center>$roundspeed</td> <td align=center>$ulspeed</td> <td align=center>$roundulspeed</td> <td align=center>$numbuilds</td> <td align=center>$total</td> <td>$times</td> </tr>\n";
}
print "</table>\n";

$csth = $db->prepare("SELECT took FROM rounds WHERE revision='$rev'");
my $rows = $csth->execute();
if ($rows) {
    my ($timeused) = $csth->fetchrow_array();
    print "<p>This build round took $timeused seconds.\n";

    for (@buildids) {
        $totalwork += $builds{$_}{score};
    }

    $ourspeed = int($totalwork / $timeused);
    printf("<br>Total client speed was $totalspeed points/second, which in ideal conditions would complete the round in %d seconds.\n", 
           $totalwork / $totalspeed);
    printf("<br>Effective round speed was $ourspeed points/second, making us %d%% efficient.\n",
           ($ourspeed * 100 / $totalspeed) + 0.5);

    print "<p>A detailed build chart is available on <a href='http://rasher.dk/rockbox/buildgraphs/graph.php?r=$rev&debug'>rasher's page</a>.\n";
          
}

&nicefoot();
