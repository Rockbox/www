#!/usr/bin/perl

require "CGI.pm";
require "./rockbox.pm";

my $req = new CGI;

my $bin = $req->param('bin');

# Bots gonna bot.  Explcitly return an error.
if ($bin =~ /^\// ||
    $bin =~ /^\./) {
   print $req->header('type text/html', '400 Bad Request');
   exit(0);
}

my $fine=0;

my $pic = playerpic($bin);
my $basedir = "/home/rockbox/download";
my $baseurl = "//download.rockbox.org";

my $desc = $builds{$bin}{name};

header("Rockbox $desc Daily Builds");

sub showother {
    my ($c)=@_;
    print "<a href=\"/daily.shtml\">daily build page</a><p>";

    print "<table class=\"rockbox\"><tr>\n";
    for(sort keys %model) {
        if($_ ne $c) {
            printf "<td><img src=\"%s\"><br><a href=\"dl.cgi?bin=%s\">%s</a></td> ",
            $model{$_}, $_, $_;
        }
    }
    print "</tr></table>\n";
}

if(!$pic) {
    print "$bin is not a fine binary name, try one of these:<p>\n";
    open(FILE, "dailymod.html");
    while (<FILE>) {
        print;
    }
    close FILE;
    exit;
}

print <<MOO
<p>
These are automated daily builds of the latest code. They contain all the
latest features, but may also contain bugs and/or undocumented changes.
The top line is the latest. 
<p>
For other players, see the <a href="daily.shtml">daily builds</a> page.
<p>
MOO
    ;

my %date;
my $dir = $bin;
opendir(DIR, "$basedir/daily/$dir");
for(grep { /^rockbox/ } readdir(DIR)) {
    /(\d{8})/;
    $date{$1}=$1;
}
closedir DIR;

print "<img src=\"$pic\" border=\"0\" align=\"left\">",
    "<table class=rockbox>\n";

$color1 = 0xc6;
$color2 = 0xd6;
$color3 = 0xf5;


print "<tr>";
for(('Date', 'Package', 'Sources', 'Changes', 'Voice', 'Rev')) {  # 'Maps'
    print "<th>$_</th>";
}
print "</tr>";

for(reverse sort keys %date) {
    my $d = $_;
    my $nice = $d;
    if($d =~ /(\d\d\d\d)(\d\d)(\d\d)/) {
        $nice = "$1-$2-$3";
    }
    $col = sprintf("style=\"background-color: #%02x%02x%02x\"",
                   $color1, $color2, $color3);
    print "<tr><td>$nice</td>";
    $color1 -= 0x18;
    $color2 -= 0x18;
    $color3 -= 0x18;

    {
        my $n=0;
        my $m = $bin;
        my $size;

        # new-style full zip:
        if( -f "$basedir/daily/$m/rockbox-${m}-${d}.zip") {
            $size = (stat("$basedir/daily/$m/rockbox-${m}-${d}.zip"))[7];
            printf("<td><a title=\"Rockbox zip package for ${desc} built $nice\" href=\"$baseurl/daily/$bin/rockbox-${m}-${d}.zip\">Rockbox</a> %d KB</td>",
                   $size/1024);
        }
        elsif($bin eq "source") {
            if (-f "$basedir/daily/source/rockbox-source-$d.tar.xz") {
                $size = (stat("$basedir/daily/source/rockbox-$d.tar.xz"))[7];
                print "<td><a href=\"$baseurl/daily/source/rockbox-source-$d.tar.xz\">tar.xz source</a></td>";
            }
        }
        else {
            print "<td></td>";
        }

        # maps!
        $rev="";

        if( -f "$basedir/daily/build-info-${d}") {
            open(R, "<$basedir/daily/build-info-${d}");
            while(<R>) {
                if(/^rev = "?(\w+)"?/) {
                    $rev = $1;
                    last;
                }
            }
            close(R);
        }
#        $map="";
#        if( -f "maps/$m/maps-rockbox-${m}-${d}.zip") {
#            $map = sprintf "<a href=\"//www.rockbox.org/maps/$bin/maps-rockbox-${m}-${d}.zip\" title=\"map file for $desc built $nice\">maps</a>",
#        }
#        print "<td>$map</td>";

            if (-f "$basedir/daily/source/rockbox-source-$d.tar.xz") {
                $size = (stat("$basedir/daily/source/rockbox-$d.tar.xz"))[7];
                print "<td><a href=\"$baseurl/daily/source/rockbox-source-$d.tar.xz\">source</a></td>";
            }


        if ( -f "$basedir/daily/changelogs/changes-$d.html") {
            print "<td><a href=\"$baseurl/daily/changelogs/changes-$d.html\" title=\"changelog for Rockbox $nice\">changelog</a></td>";
        }
        else {
            print "<td>&nbsp;</td>";
        }

	# Voices
        my $voicemod = voicename($m);
	print "<td>";
	for my $v (&allvoices) {
            my $fi = "$basedir/daily/voices/$voicemod-$d-$v.zip";
            if ( -f $fi) {
                my $size = (stat($fi))[7];
                printf("<a href=\"//download.rockbox.org/daily/voices/$voicemod-$d-$v.zip\" title=\"voice file for Rockbox $desc dated $nice\">$voices{$v}->{short}</a> %d KB<br>",
                       $size/1024);
            }
	}
	print "</td>\n";

        print "<td title=\"The build done $nice has rev $rev\"><a href=\"//git.rockbox.org/cgit/rockbox.git/commit/?id=$rev\">$rev</a></td>";
    }
    print "</tr>\n";
    $font1 = $font2 = "";
}

if (scalar keys %date == 0) {
    print "<tr><td>(No $bin daily builds available)</td></tr>\n";
}
print "</table>\n";

print "<br clear=all><p>\n";

#open(FILE, "dailymod.html");
#while (<FILE>) {
#    print;
#}
#close FILE;

footer();
