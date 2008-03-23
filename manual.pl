#!/usr/bin/perl

require "rockbox.pm";

my $basedir = "/home/dast/rockbox-manual/output";

my @list=("player",
          "recorder",
          "fmrecorder",
          "recorderv2",
          "ondiofm", "ondiosp",

          "iaudiom5", "iaudiox5", "iaudiom3"
          "h100", "h120", "h300",  "h10_5gb", "h10",

          "ipod1g2g", "ipod3g",
          "ipod4gray", "ipodcolor",
          "ipodvideo",
          "ipodmini2g",
          "ipodnano",

          "sansae200", "sansac200",
           "gigabeatf", "mrobe100",
          );

for(@list) {
    my $dir = $_;
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

    foreach $t (@list) {
        my $show = $longname{$t};
        if($t eq "ipodmini2g") {
            $show="iPod Mini";
        }
        elsif($t eq "ipodvideo") {
            $show="iPod Video";
        }
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
    for(@list) {
        my $m = $_;

        if($m eq "h120") {
            # for manuals, H100 and H120 is the same!
            $m = "h100";
        }

        printf "<td><img alt=\"$m\" src=\"$model{$m}\"><br>";
        # new-style full zip:
        #my $file = "rockbox-${m}-${d}.pdf";
        my $file = "rockbox-${m}.pdf";
        my $o;
        if( -f "$basedir/$file") {
            my $size = (stat("$basedir/$file"))[7];

            #my $page = getpages("$basedir/$file");

            #$o=sprintf("<a href=\"http://download.rockbox.org/manual/$file\">pdf</a> %dKB, ${page}p", $size/1024);
            $o=sprintf("<a href=\"http://download.rockbox.org/manual/$file\">pdf</a> <small>%d kB</small>", $size/1024);
        }

        $file = "rockbox-${m}-${d}-html.zip";
        if( -f "$basedir/$file") {
            my $size = (stat("$basedir/$file"))[7];

            $o .= sprintf("%s<a href=\"http://download.rockbox.org/manual/$file\">html-zip</a> <small>%d kB</small>", $o?"<br>":"",
                          $size/1024);
        }

        $file = "rockbox-${m}";
        if( -d "$basedir/$file") {
            $o .= sprintf("%s<a href=\"http://download.rockbox.org/manual/$file/rockbox-build.html\">online</a>", $o?"<br>":"");
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

