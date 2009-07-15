#!/usr/bin/perl

use DBI;

eval 'require "secrets.pm"';

my $building = $ARGV[0];


my @b;
my %rounds;
my %round;
my %dir; # hash per type for build dir

# number of rounds in the output table
my $maxrounds = 20;

sub getdata {
    my $dbpath = 'DBI:mysql:rockbox';
    my $db = DBI->connect($dbpath, $rb_dbuser, $rb_dbpwd) or
        warn "DBI: Can't connect to database: ". DBI->errstr;

    my $sth = $db->prepare("SELECT revision,id,errors,warnings,client,timeused FROM builds ORDER BY revision DESC") or
        warn "DBI: Can't prepare statement: ". $db->errstr;
    my $rows = $sth->execute();
    if ($rows) {
        while (my ($rev,$id,$errors,$warnings,$client,$time) = $sth->fetchrow_array()) {
            $builds{$rev}{$id}{errors} = $errors;
            $builds{$rev}{$id}{warnings} = $warnings;
            $builds{$rev}{$id}{client} = $client;
            $clients{$rev}{$client} = 1;
            $builds{$rev}{$id}{time} = $time;
            $alltypes{$id} = 1;
            if (scalar keys %builds > $maxrounds) {
                delete $builds{$rev};
            }
        }
    }
}

my $build=0;

&getdata();

print "<table class=\"buildstatus\" cellspacing=\"1\" cellpadding=\"0\"><tr>";
print "<th>rev</th>";
print "<th>score</th>";
print "<th>clients</th>";
foreach $t (sort keys %alltypes) {

    my ($a1, $a2);
    if (-f "data/rockbox-$t.zip") {
        $a1 = "<a href='data/rockbox-$t.zip' >";
        $a2 = "</a>";
    }
    print"<th>$a1<img border=0 width='16' height='130' src=\"http://build.rockbox.org/titles/$t.png\">$a2</th>\n";
}
print "</tr>\n";

#######################
my $numbuilds = scalar(keys %alltypes);
my $js;
if($building) {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) =
        gmtime(time);

    my $text ="Build in progress";
    if($prevtime) {
        my ($dsec,$dmin,$dhour,$dmday,$dmon,$dyear,$dwday,$dyday) =
            gmtime(time()+$prevtime);
        $text = sprintf("Build <span id=\"countdown_text\">expected to complete around %02d:%02d:%02d (in %dmins %dsecs)</span></a>",
                        $dhour, $dmin, $dsec,
                        $prevtime/60, $prevtime%60);
        $js = sprintf("<script type=\"text/javascript\">countdown_refresh(%d,%d,%d,%d,%d,%d);</script>",
                          $dyear+1900, $dmon, $dmday,
                          $dhour, $dmin, $dsec);
    }

    $building =~ s/ /%20/g;

    printf("<tr><td><a class=\"bstamp\" href=\"%s\">%04d-%02d-%02d %02d:%02d</a></td><td class=\"building\" colspan=\"%d\">$text</td></tr>\n",
           $building,
           $year+1900, $mon+1, $mday, $hour, $min,
           $numbuilds, gmtime());
}
#################

my $count=0;
for my $rev (sort {$b <=> $a} keys %builds) {
    my @types = keys %{$builds{$rev}};

    print "<tr align=center>\n";

    my $chlink = "<a class=\"bstamp\" href=\"http://svn.rockbox.org/viewvc.cgi?view=rev;revision=$rev\">$rev</a>";

    my $score=0;
    print "<td nowrap>$chlink</td>\n";

    my %servs;
    my %bt;

    my @tds;
    for my $type (sort keys %alltypes) {

        if (not defined $builds{$rev}{$type}{client}) {
            push @tds, "<td>&nbsp;</td>\n";
            next;
        }

        my $ok = 1;
        my $text = "0";
        my $class = "buildok";

        my $b = \%{$builds{$rev}{$type}};

        if ($$b{errors}) {
            $text=$$b{errors};
            $score += ($$b{errors} * 10) + $$b{warnings};
            if($$b{warnings}) {
                $text .= "<br>(".$$b{warnings}.")";
            }
            $class="buildfail";
        }
        elsif ($$b{warnings}) {
            $class="buildwarn";
            $text = $$b{warnings};
            $score += $$b{warnings};
        }
        
        push @tds, sprintf("<td class=\"%s\"><a class=\"blink\" href=\"shownewlog.cgi?rev=%s;type=%s\" title=\"Built by %s in %d secs\">%s</a></td>\n",
               $class,
               $rev, $type,
               $$b{client}, $$b{time},
               $text);
    }
    printf "<td>%d</td>", $score;
    printf("<td><a href=\"data/$rev-clients.html\">%d</a></td>",
           scalar(keys %{$clients{$rev}}));
    print @tds;
    print "</tr>\n";
}

printf "</table>\n";

print $js;
