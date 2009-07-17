#!/usr/bin/perl

use DBI;

eval 'require "secrets.pm"';

sub nicehead {
    my ($title)=@_;

    open(READ, "<head.html");
    while(<READ>) {
        s/_PAGE_/$title/;
        print $_;
    }
    close(READ);

}

sub nicefoot {
    open(READ, "<foot.html");
    while(<READ>) {
        print $_;
    }
    close(READ);
}

my %builds;

&getbuilds("builds");

my $rev = $ARGV[0];

my $dbpath = 'DBI:mysql:rockbox';
my $db = DBI->connect($dbpath, $rb_dbuser, $rb_dbpwd);
my $getclient_sth = $db->prepare("SELECT totscore, builds FROM clients WHERE name=?") or
    warn "DBI: Can't prepare statement: ". $db->errstr;

my $sth = $db->prepare("SELECT id,client,timeused FROM builds WHERE revision=?");
my $rows = $sth->execute($rev) + 0;
if ($rows) {
    while (my ($id, $client, $time) = $sth->fetchrow_array()) {
        $clients{$client}{$id} = $time;
        $score{$client} += $builds{$id}{score};
    }
}

&nicehead("Build client stats, revision $rev");

printf("<p>For these $rows builds, the following %d build clients participated:\n",
       scalar keys %clients);

print "<table><tr><th>Client</th> <th>Average<br>score</th> <th>Round<br>score</th> <th>Builds</th> <th>Total time</th> <th>All times</th> </tr>\n";

for my $c (sort {$score{$b} <=> $score{$a}} keys %clients) {
    my $avgscore = 0;
    my $rows = $getclient_sth->execute($c);
    if ($rows > 0) {
        my ($score, $count) = $getclient_sth->fetchrow_array();
        if ($count) {
            $avgscore = int($score / $count);
        }
    }


    my $builds;
    my $times;
    my $total;
    my $score;
    for my $id (keys %{$clients{$c}}) {
        my $t = $clients{$c}{$id};
        $total += $t;
        $times .= "$t ";
        $builds += 1;
    }
    print "<tr> <td>$c</td> <td align=center>$avgscore</td> <td align=center>$score{$c}</td> <td align=center>$builds</td> <td align=center>$total</td> <td>$times</td> </tr>\n";
}
print "</table>\n";

my $end = `tail -1000 logfile | grep "End of round $rev"`;
if ($end =~ /seconds (\d+) wasted (\d+)/) {
    my $proc = int(100 * $2 / ($1 * scalar keys %clients));
    print "<p>This build round took $1 seconds. $2 cpu seconds ($proc%) were spent on cancelled builds.\n";
}

&nicefoot();

sub getbuilds {
    my ($filename)=@_;
    open(F, "<$filename");
    while(<F>) {
        # sdl:nozip:recordersim:Recorder - Simulator:rockboxui:--target=recorder,--ram=2,--type=s
        if($_ =~ /([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):(\d+)/) {
            my ($arch, $zip, $id, $name, $file, $confopts, $score) =
                ($1, $2, $3, $4, $5, $6, $7);
            $builds{$id}{'arch'}=$arch;
            $builds{$id}{'zip'}=$zip;
            $builds{$id}{'name'}=$name;
            $builds{$id}{'file'}=$file;
            $builds{$id}{'confopts'}=$confopts;
            $builds{$id}{'score'}=$score;
            $builds{$id}{'handcount'} = 0; # not handed out to anyone
            $builds{$id}{'done'} = 0; # not done

            push @buildids, $id;
        }
    }
    close(F);
}
