#!/usr/bin/perl

use DBI;

eval 'require "secrets.pm"';

my $rev = $ARGV[0];

my $dbpath = 'DBI:mysql:rockbox';
my $db = DBI->connect($dbpath, $rb_dbuser, $rb_dbpwd);
my $sth = $db->prepare("SELECT id,client,timeused,bogomips FROM builds WHERE revision=?");
my $rows = $sth->execute($rev) + 0;
if ($rows) {
    while (my ($id, $client, $time, $bogomips) = $sth->fetchrow_array()) {
        $clients{$client}{$id} = $time;
        $speed{$client} = $bogomips;
    }
}

print "<h1>Build client stats, revision $rev</h1>\n";
printf("<p>For these $rows builds, the following %d build clients participated:\n",
       scalar keys %clients);

print "<table><tr><th>Client</th> <th>Bogomips</th> <th>Builds</th> <th>Avg time</th> <th>Total time</th> <th>All times</th> </tr>\n";

for my $c (sort {scalar keys %{$clients{$b}} <=> scalar keys %{$clients{$a}}}
           keys %clients) {
    my $builds;
    my $times;
    my $total;
    for my $id (keys %{$clients{$c}}) {
        my $t = $clients{$c}{$id};
        $total += $t;
        $times .= "$t ";
        $builds += 1;
    }
    printf("<tr> <td>$c</td> <td align=center>$speed{$c}</td> <td align=center>$builds</td> <td align=center>%d</td> <td align=center>$total</td> <td>$times</td> </tr>\n",
           int($total / $builds));
}
print "</table>\n";

my $end = `tail -100 logfile | grep "End of round"`;
if ($end =~ /seconds (\d+) /) {
    print "<p>This build round took $1 seconds.\n";
}
