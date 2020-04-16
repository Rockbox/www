#!/usr/bin/perl

require "rockbox.pm";

my $basedir = "/sites/download.rockbox.org";
my $baseurl = "https://download.rockbox.org";
my $docbasedir = "/sites/download.rockbox.org/manual";

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


print "Content-type: text/html\n\n" unless ($ARGV[0]);

opendir(DIR, "$basedir/daily") or next;
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
        my $rev;
        if( -f "$basedir/daily/build-info") {
            open(R, "<$basedir/daily/build-info");
            while(<R>) {
                if(/^rev = \W*(\w+)/) {
                    $rev = $1;
                    last;
                }
            }
            close(R);
        }

        my $icon = playerpic($m);
        printf "<td><img alt=\"$m\" src=\"$icon\"><br>";
        # new-style full zip:
        my $file = "rockbox-${m}.zip";
        my $dir = "$m/";
        if($m eq "source") {
            $file = "rockbox-${d}.7z";
        }
        elsif($m eq "install") {
            $file = "Rockbox-${d}-install.exe";
        }
        if( -f "$basedir/daily/$m/$file") {
            printf "<a href=\"https://download.rockbox.org/daily/$dir$file\">latest</a> <small>($rev)</small><br>";
        }
        print "<a href=\"/dl.cgi?bin=$m\">old</a>";

        my $docm = $m;
        if (defined $builds{$m}{manual}) {
            $docm = $builds{$m}{manual};
        }

        my $docfile = "rockbox-${docm}.pdf";
        if( -f "$docbasedir/$docfile") {
            my $size = (stat("$docbasedir/$docfile"))[7];

            #my $page = getpages("$docbasedir/$docfile");

#            printf("<p><a href=\"http://download.rockbox.org/manual/$docfile\">manual</a><br><small>%dKB, $page pages</small>", $size/1024);
            printf("<br><a href=\"https://download.rockbox.org/manual/$docfile\">manual</a> <small>%d kB</small>", $size/1024);
        }

        my $voicemod = voicename($m);
        my $voicefile="$basedir/daily/voices/${voicemod}-${d}-english.zip";
        my $voiceurl="$baseurl/daily/voices/${voicemod}-${d}-english.zip";

        if ( -f $voicefile ) {
            my $size = (stat($voicefile))[7];
            printf("<br><a href=\"$voiceurl\">voice</a> <small>%d kB</small>",
                   $size/1024);
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

