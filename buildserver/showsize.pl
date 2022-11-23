#!/usr/bin/perl
require "./rbmaster.pm";

$ENV{'TZ'} = "UTC";

my $rounds = 20;
my @revisions;
my %targets;
my %compiles;
my %lines;
my %deltas;

sub getdata {
    db_connect();
    my %revs;    

    $rounds++;

    $csth = $db->prepare("SELECT revision,clients,took,UNIX_TIMESTAMP(time) FROM rounds ORDER BY time DESC limit $rounds");
    my $rows = $csth->execute();
    if ($rows) {
        while (my ($rev, $clients,$took,$time) = $csth->fetchrow_array()) {
	    push(@revisions, $rev);
            $round{$rev}{clients} = $clients;
            $round{$rev}{took} = $took;
            $round{$rev}{time} = $time;

            #If a round completely failed, compensate!
            if (!defined($compiles{$rev})) {
                foreach my $id (keys(%found)) {
                   $compiles{$rev}{$id} = {};
                }
            }
        }
    }

    my $maxrows = ($rounds + 1) * (scalar keys %builds);
    my $list = "'" . join("','", keys(%round)) . "'";

    my $sth = $db->prepare("SELECT time,revision,id,ramsize,binsize FROM builds WHERE revision in ($list) and ulsize != 0 ORDER BY time DESC, id ASC limit $maxrows") or
        warn "DBI: Can't prepare statement: ". $db->errstr;
    my $rows = $sth->execute();
    if ($rows) {
        while (my ($time,$rev,$id,$ramsize,$binsize) = $sth->fetchrow_array()) {
	    $revs{$rev} = $time;
	    $targets{$id} = 1;
            $compiles{$rev}{$id}{ram} = $ramsize;
            $compiles{$rev}{$id}{bin} = $binsize;
	}
    }

#    for my $r (sort {$revs{$a} cmp $revs{$b}} keys %revs) {
#	unshift(@revisions, $r);
#    }

  $rounds--;
  unshift(@revisions);
}

# binsize ramsize per file.

getbuilds();
getdata();

# Churn on data to build the table.
for (my $i = 0; $i < $rounds ; $i++) {
    my $totdelta = 0;
    my $builds = 0;
    my $rev = $revisions[$i];
    
    foreach my $id (sort(keys(%targets))) {
	my $lastrev = 0;
	if (!defined($compiles{$rev}{$id})) {
	    # Build did not complete
	    $compiles{$rev}{$id}{text} = '<td title="Build did not complete">n/a</td>';
	    next;
	}
	for (my $j = $i+1 ; $j < ($rounds+1) ; $j++) {
	    $lastrev = $revisions[$j];
	    last if (defined($compiles{$lastrev}{$id}));
	}
	if ($lastrev eq 0) {
	    # No successful previous build to reference
	    $compiles{$rev}{$id}{text} = "<td class=\"$cl\" title=\"Bin: $compiles{$rev}{$id}{bin} Ram: $compiles{$rev}{$id}{ram}\"> ? </td>";	    
	    next;
	}
	if ($compiles{$rev}{$id}{ram} == 0 || $compiles{$rev}{$id}{bin} == 0) {
	    # Current build does not have numbers;
	    $compiles{$rev}{$id}{text} = '<td title="Build does not have sizs stored"> - </td>';
	    next;
	}
	if ($compiles{$lastrev}{$id}{bin} == 0 || $compiles{$lastrev}{$id}{ram} == 0) {
	    # Last build does not have numbers;
	    $compiles{$rev}{$id}{text} = "<td class=\"$cl\" title=\"Bin: $compiles{$rev}{$id}{bin} Ram: $compiles{$rev}{$id}{ram}\"> ? </td>";	    	    
	    next;
	}
	
	# Work out size deltas.
	my $ramdelta = $compiles{$rev}{$id}{ram} - $compiles{$lastrev}{$id}{ram};
	my $bindelta = $compiles{$rev}{$id}{bin} - $compiles{$lastrev}{$id}{bin};

	my $cl = "";
	if ($ramdelta > 16) {
	    $cl = "buildfail";
	} elsif ($ramdelta < -16) {
	    $cl = "buildok";
	}
	$compiles{$rev}{$id}{text} = "<td class=\"$cl\" title=\"Bin: $bindelta/$compiles{$rev}{$id}{bin} Ram: $ramdelta/$compiles{$rev}{$id}{ram}\">$ramdelta</td>";
	$totdelta += $ramdelta;
	if ($ramdelta) {
            $builds++;
        }

#	$cl = "";
#	if ($bindelta > 16) {
#	    $cl = "buildfail";
#	} elsif ($bindelta < -16) {
#	    $cl = "buildok";
#	}
#	$compiles{$rev}{$id}{text} = "<td class=\"$cl\" title=\"Bin: $bindelta/$compiles{$rev}{$id}{bin} Ram: $ramdelta/$compiles{$rev}{$id}{ram}\">$bindelta</td>";
#	$totdelta += $bindelta;
#	if ($bindelta) {
#            $builds++;
#        }
    }
    
    my $cl = "";    
    if ($builds > 0) {
	$deltas{$rev} = int($totdelta / $builds + 0.5);
	if ($deltas{$rev} > 16) {
	    $cl = "buildfail";
	} elsif ($deltas{$rev} < -16) {
	    $cl="buildok";
	}
    } else {
	$deltas{$rev} = 0;
    }
    $deltas{$rev} = "<td class=\"$cl\">$deltas{$rev}</td>"
}

print <<MOO

<p> RAM and binary size deltas of the main Rockbox images during the most
    recent commits.  Hover over the delta to get the exact size in bytes.

MOO
;
print "<table class=\"buildstatus\" cellspacing=\"1\" cellpadding=\"2\">\n";
print "<tr><th>Revision</th>\n";
foreach my $t (sort(keys(%targets))) {
    print"<th><span class=\"rotate\">$t</span></th>\n";
#    print "<th><img width='16' height='130' alt=\"$t\" src=\"/titles/$t.png\"></td>\n";
}
print "<th>Avg Change Delta</th>\n";
print "</tr>\n";

for (my $i = 0; $i < $rounds ; $i++) {
    my $rev = $revisions[$i];
    print "<tr>\n";
    my $shortrev = substr($rev, 0, 8);
    print "<td nowrap><a class=\"bstamp\" href=\"//git.rockbox.org/cgit/rockbox.git/commit/?id=$rev\">$shortrev</a></td>\n";

    foreach my $id (sort(keys(%targets))) {
	print "$compiles{$rev}{$id}{text}\n";
    }

    print "$deltas{$rev}\n";
    print "</tr>\n";
}

print "</table>";

