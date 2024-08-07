#!/usr/bin/perl

require "./rockbox.pm";

my $basedir = "/home/rockbox/download/daily/manual";

for my $m (manualbuilds()) {
    opendir(DIR, "$basedir") or next;
    my @files = sort grep { /^rockbox/ } readdir(DIR);
    closedir DIR;

    for(@files) {
        /(20\d+)/;
        $date{$1}=$1;
    }
}

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

for(reverse sort keys %date) {
    my $d = $_;
    my $nice = $d;
    if($d =~ /(\d\d\d\d)(\d\d)(\d\d)/) {
        $nice = "$1-$2-$3";
    }
    print "<table class=rockbox cellpadding=\"0\"><tr valign=\"top\">\n";

    my $count = 0;
    my $split = 8; # number of column ons each line
    my $x = 0;
    my @head;

    foreach my $t (manualbuilds()) {
        my $show = $builds{$t}{name};
        $head[$x] .= "<th>$show</th>\n";
	$count++;
	if ($count == $split) {
            $count=0;
	    $x++;
	}
    }
    print "$head[0]</tr><tr valign=\"top\">\n";

    $x=1;
    $count = 0;
    for my $b (manualbuilds()) {
        my $m = manualname($b);
        my $pic = playerpic($b);
        printf "<td><img alt=\"$m\" src=\"$pic\"><br>";
        # new-style full zip:
        #my $file = "rockbox-${m}-${d}.pdf";
        my $file = "rockbox-${m}.pdf";
        my $o;

        $html = "$basedir/rockbox-${m}/rockbox-build.html";
        if (open HTML, "<$html") {
            my @lines = grep /cmss-12/, <HTML>;
            close HTML;
            if ($lines[0] =~ />(.+?)</) {
                printf("<small>$1</small>");
                $o = " ";
            }
        }

        if( -f "$basedir/$file") {
            my $size = (stat("$basedir/$file"))[7];

            #my $page = getpages("$basedir/$file");

            #$o=sprintf("<a href=\"//download.rockbox.org/manual/$file\">pdf</a> %dKB, ${page}p", $size/1024);
            $o=sprintf("%s<a href=\"//download.rockbox.org/daily/manual/$file\">pdf</a> <small>%d kB</small>", $o?"<br>":"", $size/1024);
        }

        $file = "rockbox-${m}-html.zip";
        if( -f "$basedir/$file") {
            my $size = (stat("$basedir/$file"))[7];

            $o .= sprintf("%s<a href=\"//download.rockbox.org/daily/manual/$file\">html-zip</a> <small>%d kB</small>", $o?"<br>":"", $size/1024);

            $file = "rockbox-${m}";
            $o .= sprintf("%s<a href=\"//download.rockbox.org/daily/manual/$file/rockbox-build.html\">online</a>", $o?"<br>":"");
        }
        print "$o\n";

	$count++;
	if ($count == $split) {
            $count=0;
	    print "</tr><tr valign=\"top\">$head[$x++]</tr><tr valign=\"top\">\n";
	}
    }
    print "</tr>\n";
    last;
}
print "</table>\n";

