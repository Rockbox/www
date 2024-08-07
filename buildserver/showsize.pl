#!/usr/bin/perl
require "./rbmaster.pm";

$ENV{'TZ'} = "UTC";

my $rounds = 20;
my @revisions;
my %targets;
my %compiles;
my %lines;
my %deltas1;
my %deltas2;

if (defined($ARGV[0])) {
    $mode = 'bin';
} else {
    $mode = 'ram';
}

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
	    if ($id !~ /manual/) {
		$targets{$id} = 1;
	    }
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
    my $totdelta1 = 0;
    my $totdelta2 = 0;
    my $builds1 = 0;
    my $builds2 = 0;
    my $rev = $revisions[$i];

    foreach my $id (sort(keys(%targets))) {
	my $lastrev = 0;
	if (!defined($compiles{$rev}{$id})) {
	    # Build did not complete
	    $compiles{$rev}{$id}{text1} = '<td title="Build did not complete">n/a</td>';
	    $compiles{$rev}{$id}{text2} = '<td title="Build did not complete">n/a</td>';
	    next;
	}
	for (my $j = $i+1 ; $j < ($rounds+1) ; $j++) {
	    $lastrev = $revisions[$j];
	    last if (defined($compiles{$lastrev}{$id}));
	}
	if ($lastrev eq 0) {
	    # No successful previous build to reference
	    $compiles{$rev}{$id}{text1} = "<td class=\"$cl\" title=\"Bin: $compiles{$rev}{$id}{bin} Ram: $compiles{$rev}{$id}{ram}\"> ? </td>";
	    $compiles{$rev}{$id}{text2} = "<td class=\"$cl\" title=\"Bin: $compiles{$rev}{$id}{bin} Ram: $compiles{$rev}{$id}{ram}\"> ? </td>";
	    next;
	}
	if ($compiles{$rev}{$id}{ram} == 0 || $compiles{$rev}{$id}{bin} == 0) {
	    # Current build does not have numbers;
	    $compiles{$rev}{$id}{text1} = '<td title="Build does not have sizs stored"> - </td>';
	    $compiles{$rev}{$id}{text2} = '<td title="Build does not have sizs stored"> - </td>';
	    next;
	}
	if ($compiles{$lastrev}{$id}{bin} == 0 || $compiles{$lastrev}{$id}{ram} == 0) {
	    # Last build does not have numbers;
	    $compiles{$rev}{$id}{text1} = "<td class=\"$cl\" title=\"Bin: $compiles{$rev}{$id}{bin} Ram: $compiles{$rev}{$id}{ram}\"> ? </td>";
	    $compiles{$rev}{$id}{text2} = "<td class=\"$cl\" title=\"Bin: $compiles{$rev}{$id}{bin} Ram: $compiles{$rev}{$id}{ram}\"> ? </td>";
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
	$compiles{$rev}{$id}{text1} = "<td class=\"$cl\" title=\"Bin: $bindelta/$compiles{$rev}{$id}{bin} Ram: $ramdelta/$compiles{$rev}{$id}{ram}\">$ramdelta</td>";
	$totdelta1 += $ramdelta;
	if ($ramdelta) {
            $builds1++;
        }

	$cl = "";
	if ($bindelta > 16) {
	    $cl = "buildfail";
	} elsif ($bindelta < -16) {
	    $cl = "buildok";
	}
	$compiles{$rev}{$id}{text2} = "<td class=\"$cl\" title=\"Bin: $bindelta/$compiles{$rev}{$id}{bin} Ram: $ramdelta/$compiles{$rev}{$id}{ram}\">$bindelta</td>";
	$totdelta2 += $bindelta;
	if ($bindelta) {
            $builds2++;
        }
    }

    my $cl = "";
    if ($builds1 > 0) {
	$deltas1{$rev} = int($totdelta1 / $builds1 + 0.5);
	if ($deltas1{$rev} > 16) {
	    $cl = "buildfail";
	} elsif ($deltas1{$rev} < -16) {
	    $cl="buildok";
	}
    } else {
	$deltas1{$rev} = 0;
    }
    $deltas1{$rev} = "<td class=\"$cl\">$deltas1{$rev}</td>";

    my $cl = "";
    if ($builds2 > 0) {
	$deltas2{$rev} = int($totdelta2 / $builds2 + 0.5);
	if ($deltas2{$rev} > 16) {
	    $cl = "buildfail";
	} elsif ($deltas2{$rev} < -16) {
	    $cl="buildok";
	}
    } else {
	$deltas2{$rev} = 0;
    }
    $deltas2{$rev} = "<td class=\"$cl\">$deltas2{$rev}</td>";
}

print <<MOO
<p> Size deltas of the main Rockbox images during the most
    recent commits. Hover over the delta to get the exact size in bytes.</br>
    If the build was successful the name is a download link.
  Current mode: $mode </p>
MOO
;
print "<table class=\"buildstatus\" cellspacing=\"1\" cellpadding=\"2\">\n";
print "<tr><th>Revision</th>\n";
foreach my $t (sort(keys(%targets))) {
    my $a1 = "";
    my $a2 = "";
    my $name = "";
    if (defined($builds{$t}{name})) {
      $name = $builds{$t}{name};
    } else {
      $name = "$t (retired)";
    }
    if (-f "data/rockbox-$t.zip") {
        $a1 = "<a href='data/rockbox-$t.zip' >";
        $a2 = "</a>";
    }
    print"<th><span class=\"rotate\">$a1$name$a2</span></th>\n";
}
print "<th>Avg Change Delta</th>\n";
print "</tr>\n";

for (my $i = 0; $i < $rounds ; $i++) {
    my $rev = $revisions[$i];
    print "<tr>\n";
    my $shortrev = substr($rev, 0, 10);
    print "<td nowrap><a class=\"bstamp\" href=\"//git.rockbox.org/cgit/rockbox.git/commit/?id=$rev\">$shortrev</a></td>\n";

    foreach my $id (sort(keys(%targets))) {
	if ($mode eq 'bin') {
	    print "$compiles{$rev}{$id}{text2}\n";
	} else {
	    print "$compiles{$rev}{$id}{text1}\n";
	}
    }
    if ($mode eq 'bin') {
	print "$deltas2{$rev}\n";
    } else {
	print "$deltas1{$rev}\n";
    }
    print "</tr>\n";
}

print "</table>";
