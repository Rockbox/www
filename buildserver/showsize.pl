#!/usr/bin/perl

my $dir="data";

opendir(DIR, $dir) || die "can't opendir $dir: $!";
my @logs = sort grep { /.sizes$/ && -f "$dir/$_" } readdir(DIR);
closedir DIR;

my %title;
my $rounds;
my %lines;

my %this;
my %delta;

my %targsort = ('player' => 5,
                'recorder' => 10,
                'recorder8mb' => 20,
                'fmrecorder' => 30,
                'fmrecorder8mb' => 40,
                'recorderv2' => 50,
                'ondiofm' => 60,
                'ondiosp' => 70,
                'iaudiom3' => 80,
                'iaudiom5' => 85,
                'iaudiox5' => 90,
                "h100" => 100,
                "h120" => 110,
                "h300" => 120,
                "h10_5gb" => 130,
                "h10" => 140,
                "hdd1630" => 145,
                "ipod1g2g" => 150,
                "ipod3g" => 160,
                "ipod4gray" => 170,
                "ipodcolor" => 180,
                "ipodvideo" => 190,
                "ipodvideo64mb" => 200,
                "ipodmini1g" => 210,
                "ipodmini2g" => 220,
                "ipodnano" => 230,
                "sansae200" => 240,
                "sansac200" => 245,
                "clip" => 250,
                "fuze" => 260,
                "sansae200v2" => 265,
                "m200v4" => 270,
                "gigabeatf" => 280,
                "gigabeats" => 290,
                "mrobe500" => 300,
                "mrobe100" => 310,
                "cowond2" => 350,
                "creativezvm30" => 400,
                "creativezvm60" => 410,
                "creativezenvision" => 420,
                'ondavx747' => 500,
                'ondavx767' => 510,
                'yh820' => 600,
                'yh920' => 610,
                'yh925' => 620,
                );

sub titlesort {
    return $targsort{$a} <=> $targsort{$b};
}

sub singlefile {
    my($file)=@_;
    my @o;
    my %single;
    my $totaldelta=0;
    my $models=0;

    open(F, "<$file");
    while(<F>) {
	if(/^([^ :]*) *: *(\d+) *(\d*)/) {
	    my ($name, $size, $ram)=($1, $2, $3);
	    $title{$name} += $size;
	    my $delta = 0;
            my $ramdelta = 0;
            my $t;
            $ram += 0;
            my $title;

	    if($thisram{$name} && $ram) {
		$ramdelta = $ram - $thisram{$name};
		my $cl="";
		if($ramdelta > 16) {
		    $cl = "buildfail";
		}
		elsif($ramdelta < -16) {
		    $cl="buildok";
		} 
		$t = "<td class=\"$cl\">$ramdelta</td>";
	    }
	    else {
		$t = "<td>-</td>";
	    }
            $title="\nRAM: $ramdelta/$ram bytes";
            $singleram{$1}=$t;

            my $t2;

	    if($this{$name} && $size) {
		$delta = $size - $this{$name};
            }

            my $delta2 = ($delta + $ramdelta)/2;

            my $cl="";
            if($delta2 > 16) {
                $cl = "buildfail";
            }
            elsif($delta2 < -16) {
                $cl="buildok";
            }

            $t2 ="<td class=\"$cl\" title=\"Bin: $delta/$size bytes $title\">${delta2}</td>";

            $single{$1} = $t2;
	    $totaldelta += $delta2;
	    if($size) {
		$this{$name}=$size;
	    }
	    if($ram) {
		$thisram{$name}=$ram;
	    }
	    $models++;
	} 
    }
    close(F);

    for my $t (sort titlesort keys %title) {
        my $tx = $single{$t};
        if(!$tx) {
            $tx="<td>&nbsp;</td>";
        }
	$lines{$file} .= $tx;
    }
    
    my $cl="";
    if($models > 0) {
	$totaldelta = sprintf("%d", $totaldelta/$models);
    }
    if($totaldelta > 16) {
	$cl = "buildfail";
    }
    elsif($totaldelta < -16) {
	$cl="buildok";
    } 
    $lines{$file} .= "<td class=\"$cl\">$totaldelta</td>";

}


foreach my $l (@logs) {
    if( -s "$dir/$l") {
	singlefile("$dir/$l");
	$rounds++;
    }
}

print <<MOO

<p> File size deltas of the binary main Rockbox images during the most recent
 commits. Hover over the delta to get the exact file size in bytes.

MOO
;
print "<table class=\"buildstatus\" cellspacing=\"1\" cellpadding=\"2\"><tr><th>Revision</th>\n";
for my $t (sort titlesort keys %title) {
    print "<td><img width='16' height='130' alt=\"$t\" src=\"/dist/build-$t.png\"></td>\n";
}
print "<th>Delta</th>\n";
print "</tr>\n";

my $c;
foreach my $l (reverse sort @logs) {
    if($lines{"$dir/$l"}) {
        $l =~ /^(\d+).sizes$/;
        my $rev = $1;
        $b = "<a class=\"bstamp\" href=\"http://svn.rockbox.org/viewvc.cgi?view=rev;revision=$rev\">$rev</a>";

	print "<tr><td nowrap>$b</td>";
	print $lines{"$dir/$l"}."\n";
	print "<td><a href=\"/cvsmod/$l\">log</a></td>";
	print "</tr>\n";

	if($c++ > 18) {
	    last;
	}
    }
}
print "</table>";

