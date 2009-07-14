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
my $sth = $db->prepare("SELECT id,client,timeused,bogomips FROM builds WHERE revision=?");
my $rows = $sth->execute($rev) + 0;
if ($rows) {
    while (my ($id, $client, $time, $bogomips) = $sth->fetchrow_array()) {
        $clients{$client}{$id} = $time;
        $score{$client} += $builds{$id}{score};
        $speed{$client} = $bogomips;
    }
}

&nicehead("Build client stats, revision $rev");

printf("<p>For these $rows builds, the following %d build clients participated:\n",
       scalar keys %clients);

print "<table><tr><th>Client</th> <th>Bogomips</th> <th>Score</th> <th>Builds</th> <th>Avg time</th> <th>Total time</th> <th>All times</th> </tr>\n";

for my $c (sort {$score{$b} <=> $score{$a}} keys %clients) {
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
    printf("<tr> <td>$c</td> <td align=center>$speed{$c}</td> <td align=center>$score{$c}</td> <td align=center>$builds</td> <td align=center>%d</td> <td align=center>$total</td> <td>$times</td> </tr>\n",
           int($total / $builds));
}
print "</table>\n";

my $end = `tail -100 logfile | grep "End of round"`;
if ($end =~ /seconds (\d+) wasted (\d+)/) {
    print "<p>This build round took $1 seconds. $2 cpu seconds were spent on cancelled builds.\n";
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
