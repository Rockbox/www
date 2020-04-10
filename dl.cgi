#!/usr/bin/perl

require "CGI.pm";
require "./rockbox.pm";

my $req = new CGI;

my $bin = $req->param('bin');

my $fine=0;

my $pic = playerpic($bin);
my $basedir = "/home/rockbox/download";
#XXX my $baseurl = "https://download.rockbox.org";
my $baseurl = "http://download.rockbox.org";

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
    print `./dailymod.pl`;
    exit;
}

print <<MOO
These are automated daily builds of the latest code. They contain all the
latest features. They may also contain bugs and/or undocumented changes...
The top line is the latest. This build is for $desc.
<p>
MOO
    ;

my %date;
my $dir = $bin;
opendir(DIR, "$basedir/daily/$dir") or next;
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
for(('Date', 'Package', 'Maps', 'Changes', 'Voice', 'Rev')) {
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
            if (-f "$basedir/daily/source/rockbox-$d.tar.bz2") {
                $size = (stat("$basedir/daily/source/rockbox-$d.tar.bz2"))[7];
                print "<td><a href=\"daily/source/rockbox-$d.tar.bz2\">bz2 source</a></td>";
            }
            elsif(-f "$basedir/daily/source/rockbox-$d.7z") {
                $size = (stat("$basedir/daily/source/rockbox-$d.7z"))[7];
                print "<td><a href=\"daily/source/rockbox-$d.7z\">7zip source</a></td>";
            }
        }
        else {
            print "<td></td>";
        }
        # maps!
        $map="";
        $rev="";

        if( -f "$basedir/daily/build-info-${d}") {
            open(R, "<$basedir/daily/build-info-${d}");
            while(<R>) {
                if(/^rev = (\w+)/) {
                    $rev = $1;
                    last;
                }
            }
            close(R);
        }
        if( -f "maps/$m/maps-rockbox-${m}-${d}.zip") {
            $map = sprintf "<a href=\"http://www.rockbox.org/maps/$bin/maps-rockbox-${m}-${d}.zip\" title=\"map file for $desc built $nice\">maps</a>",
        }
        print "<td>$map</td>";

        if ( -f "$basedir/daily/changelogs/changes-$d.html") {
            print "<td><a href=\"$baseurl/daily/changelogs/changes-$d.html\" title=\"changelog for Rockbox $nice\">changelog</a></td>";
        }
        else {
            print "<td>&nbsp;</td>";
        }

        my $fi = "/home/rockbox/download/daily/voices/$m-$d-english.voice";
        my $fi2 = "/home/rockbox/download/daily/voices/$m-$d-english.zip";
        if ( -f $fi2) {
            my $size = (stat($fi2))[7];
            printf("<td><a href=\"http://download.rockbox.org/daily/voices/$m-$d-english.zip\" title=\"voice file for Rockbox $desc dated $nice\">voice zip</a> %d KB</td>",
                   $size/1024);
        }
        elsif ( -f $fi) {
            my $size = (stat($fi))[7];
            printf("<td><a href=\"http://download.rockbox.org/daily/voices/$m-$d-english.voice\" title=\"voice file for Rockbox $desc dated $nice\">english.voice</a> %d KB</td>",
                   $size/1024);
        }
        else {
            print "<td>absent</td>";
        }

        print "<td title=\"The build done $nice has rev $rev\">$rev</td>";
    }
    print "</tr>\n";
    $font1 = $font2 = "";
}

if (scalar keys %date == 0) {
    print "<tr><td>(No $bin daily builds available)</td></tr>\n";
}
print "</table>\n";

print "<br clear=all><p>\n";

print `./dailymod.pl 1`;

footer();
