#!/usr/bin/perl

push (@INC, "./");

require "./rockbox.pm";

my $basedir = "/home/rockbox/download";
my $baseurl = "//download.rockbox.org";
my $docbasedir = "/home/rockbox/download/manual";

sub getpages {

    my ($file)=@_;

    my @o = `pdfinfo $file`;
    for(@o) {
        if($_ =~ /^Pages:[ \t]*(\d+)/) {
            return $1;
        }
    }
    return 0;
}

opendir(DIR, "$basedir/daily") or die;
my @files = sort grep { /^build-info/ } readdir(DIR);
closedir DIR;

for (@files) {
    /(20\d+)/;
    $date{$1}=$1;
}

my $split = 8;

for(reverse sort keys %date) {
    my $d = $_;
    my $nice = $d;
    if($d =~ /20(\d\d)(\d\d)(\d\d)/) {
        $nice = "20$1-$2-$3";
    }

    my $rev;
    if( -f "$basedir/daily/build-info") {
        open(R, "<$basedir/daily/build-info");
        while(<R>) {
            if(/rev\s?=\s?\"?(\w+)\"?/) {
                $rev = $1;
                last;
            }
        }
        close(R);
    }

    print "<p><b>All of these builds were generated using the <a href=\"//download.rockbox.org/daily/source/rockbox-source-${d}.tar.xz\">${d} source code snapshot</a> corresponding to <a href=\"//git.rockbox.org/cgit/rockbox.git/commit/?id=${rev}\">revision ${rev}</a></b></p>\n";
    if (-f "$basedir/daily/changelogs/changes-${d}.html") {
        print "<p><a href=\"https://download.rockbox.org/daily/changelogs/changes-${d}.html\">Changes from the previous daily build</a></p>\n";
    } else {
        print "<p>No changes from the previous daily build\n";
    }
    print "<p><a href=\"https://download.rockbox.org/daily/fonts/rockbox-fonts-${d}.zip\">Fonts file for the ${d} builds</a></p>";
    print "<p><i>Please note that generating these new builds takes upwards of a couple of hours, and if you visit this page while builds are in progress you may see it only partially updated.<br/> Please check back later if what you want is missing, or use the 'older builds' links to grab something from a previous daily build.</i>\n";
    print "<table class=rockbox cellpadding=\"0\">\n";

    $color1 -= 0x18;
    $color2 -= 0x18;
    $color3 -= 0x18;

    my $count = 0;
    my $x = 0;
    my @head;

    # build table headers
    foreach my $t (&usablebuilds) {
        $head[$x] .= "<th>$builds{$t}{name}</th>\n";
	$count++;
	if ($count == $split) {
	    $x++;
            $count=0;
	}
    }

    $count = 0;
    $x=0;
    for my $m (&usablebuilds) {
        if(!$count++) {
            print "<!-- $m --><tr valign=\"top\">$head[$x]</tr>\n<tr valign=\"top\">\n";
            $x++;
        }

	printf "<td>\n";
        my $icon = playerpic($m);'
        printf "<table cellpadding=\"0\" cellspacing=\"0\" align=\"center\"><tr><td height=\"85px\"><img alt=\"$m\" src=\"$icon\"></td></tr></table><br/>";
        # new-style full zip:
        my $file = "rockbox-${m}-${d}.zip";
        my $dir = "$m/";
        if($m eq "source") {
            $file = "rockbox-${d}.tar.xz";
        }
        elsif($m eq "install") {
            $file = "Rockbox-${d}-install.exe";
        }
        if( -f "$basedir/daily/$m/$file") {
            my $size = (stat("$basedir/daily/$m/$file"))[7] / 1024;
            printf "<a href=\"//download.rockbox.org/daily/$dir$file\">rockbox</a> <small>%d kB</small>", $size;
        }

        my $docm = $m;
        if (defined $builds{$m}{manual}) {
            $docm = $builds{$m}{manual};
        }

	# Voices
        my $voicemod = voicename($m);

	for my $v (&allvoices) {
            my $voicefile="$basedir/daily/${voicemod}/voice-${voicemod}-${d}-$v.zip";
            my $voiceurl="$baseurl/daily/${voicemod}/voice-${voicemod}-${d}-$v.zip";

            if ( -f $voicefile ) {
                my $size = (stat($voicefile))[7];
                printf("<br><a href=\"$voiceurl\">voice ($voices{$v}->{short})</a> <small>%d kB</small>",
                   $size/1024);
            }
	}

	# Documentation
        my $docfile = "rockbox-${docm}.pdf";
        if( -f "$docbasedir/$docfile") {
            my $size = (stat("$docbasedir/$docfile"))[7];

            #my $page = getpages("$docbasedir/$docfile");

#            printf("<p><a href=\"//download.rockbox.org/manual/$docfile\">manual</a><br><small>%dKB, $page pages</small>", $size/1024);
            printf("<br><a href=\"//download.rockbox.org/manual/$docfile\">manual (pdf)</a> <small>%d kB</small>", $size/1024);
        } else {
	  print "<br>\n";
	}
        $docfile = "rockbox-${docm}-html.zip";
        if( -f "$docbasedir/$docfile") {
            my $size = (stat("$docbasedir/$docfile"))[7];

            #my $page = getpages("$docbasedir/$docfile");

#            printf("<p><a href=\"//download.rockbox.org/manual/$docfile\">manual</a><br><small>%dKB, $page pages</small>", $size/1024);
            printf("<br><a href=\"//download.rockbox.org/manual/$docfile\">manual (html)</a> <small>%d kB</small>", $size/1024);
        } else {
	  print "<br>\n";
	}

        print "<br><a href=\"/dl.cgi?bin=$m\">older builds</a>";

        print "</td>\n";

	if ($count == $split) {
            $count=0;
	}
    }
    print "</tr>\n";
    last;
}
print "</table>\n";
