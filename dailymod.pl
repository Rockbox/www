#!/usr/bin/perl

require "rockbox.pm";

my $basedir = "/home/dast/rockbox-build/daily-build";
my $docbasedir = "/home/dast/rockbox-manual/output";

my @list=("player",
          "recorder", "recorder8mb",
          "fmrecorder", "fmrecorder8mb",
          "recorderv2",
          "ondiofm", "ondiosp",
          "h100", "h120", "h300",

          "ipodcolor", "ipodnano", "ipod4gray", "ipodvideo", "ipodvideo64mb",
          "ipod3g",
          "ipodmini2g", "ipodmini1g",
          "iaudiox5", "iaudiom5", "h10", "h10_5gb", "gigabeatf", "sansae200",

          # install and source are special cases
          #"install",
          "source", "fonts");

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

for(@list) {
    my $dir = $_;
    opendir(DIR, "$basedir/$dir") or next;
    my @files = sort grep { /^rockbox/ } readdir(DIR);
    closedir DIR;

    for(@files) {
        /(20\d+)/;
        $date{$1}=$1;
    }
}

my $split = 8;

for(reverse sort keys %date) {
    my $d = $_;
    my $nice = $d;
    if($d =~ /(\d\d\d\d)(\d\d)(\d\d)/) {
        $nice = "$1-$2-$3";
    }
    print "<table class=rockbox cellpadding=\"0\">\n";

    $color1 -= 0x18;
    $color2 -= 0x18;
    $color3 -= 0x18;
    
    my $count = 0;
    my $x = 0;
    my @head;

    foreach $t (@list) {
        my $show = $t;
        $show =~ s/recorder/rec/;
        # Remove the comment below to get long names
        $show = $longname{$t};
        $head[$x] .= "<th>$show</th>\n";
	$count++;
	if ($count == $split) {
	    $x++;
            $count=0;
	}
    }
    #print "<tr valign=\"top\">$head[0]</tr>\n";

    $count = 0;
    $x=0;
    for(@list) {
        my $m = $_;
        if(!$count++) {
            print "<!-- $m --><tr valign=\"top\">$head[$x]</tr>\n<tr valign=\"top\">\n";
            $x++;
        }

        printf "<td><img alt=\"$m\" src=\"$model{$m}\"><br>";
        # new-style full zip:
        my $file = "rockbox-${m}.zip";
        my $dir = "$_/";
        if($m eq "source") {
            $file = "rockbox-${d}.tar.bz2";
      #      $dir="";
        }
        elsif($m eq "install") {
            $file = "Rockbox-${d}-install.exe";
        }
        if( -f "$basedir/$m/$file") {
            printf "<a href=\"http://download.rockbox.org/daily/$dir$file\">latest</a> / ";
        }
        print "<a href=\"/dl.cgi?bin=$_\">old</a>";

        my $docm = $m;
        if($docm eq "h120") {
            $docm="h100";
        }
        elsif($docm eq "recorder8mb") {
            $docm="recorder";
        }
        elsif($docm eq "fmrecorder8mb") {
            $docm="fmrecorder";
        }
        elsif($docm eq "ipodmini1g") {
            $docm="ipodmini2g";
        }
        elsif($docm eq "ipodvideo64mb") {
            $docm="ipodvideo";
        }

        my $docfile = "rockbox-${docm}.pdf";
        if( -f "$docbasedir/$docfile") {
            my $size = (stat("$docbasedir/$docfile"))[7];

            #my $page = getpages("$docbasedir/$docfile");

#            printf("<p><a href=\"http://download.rockbox.org/manual/$docfile\">manual</a><br><small>%dKB, $page pages</small>", $size/1024);
            printf("<p><a href=\"http://download.rockbox.org/manual/$docfile\">manual</a> <small>%d kB</small>", $size/1024);
        }

        print "</td>\n";

	if ($count == $split) {
            $count=0;
	}
    }
    print "</tr>\n";
    last;
}
print "</table>\n";

