#!/usr/bin/perl

push (@INC, "./");
require "rockbox.pm";

my $basedir = "/home/rockbox/build";
my %revs;

sub buildtable {
    print "<p><table class='rockbox' cellpadding=\"0\"><tr valign=top>\n";
    for my $m (usablebuilds()) {
        if( ($m =~ /source/ ) || -r "$basedir/data/rockbox-$m.zip") {
            my $pack="data/rockbox-$m.zip";
            my $name= $builds{$m}{name},
            my $version = "";
            my $rev="broken?";
	    my @ver = `unzip -p data/rockbox-$m.zip .rockbox/rockbox-info.txt`;
	    $version = (grep /^Version/, @ver)[0];
	    chomp $version;
	    if($version =~ /^Version: *(\w+)/) {
		$rev = $1;
	    }
	    else {
		print "<br>Failed regex: $version\n";
	    }
	    $revs{$m} = $rev;
            if($col++ > 7) {
                print "</tr><tr valign=\"top\">";
                $col=1;
            }
            my $manual;
            if (-r "$basedir/data/rockbox-${m}manual.pdf") {
               $pack="data/rockbox-${m}manual.pdf";
               $manual .= "<br/><a href=\"$pack\">PDF Manual</a>";
            }
            if (-r "$basedir/data/rockbox-${m}htmlmanual.zip") {
               $pack="data/rockbox-${m}htmlmanual.zip";
               $manual .= "<br/><a href=\"$pack\">HTML Manual</a>";
            }
            printf("<td align='center'><a href=\"$pack\" title=\"$name\"><img border=\"0\" src=\"//www.rockbox.org%s\" alt=\"$name\"><p>$name</a><br><small>$rev</small>$manual</td>\n",
                   playerpic($m));
        }
        else {
            #print "<br>MISSING: $basedir/data/rockbox-$m.zip\n";
        }
    }
    print "</tr></table>";
}

header_b("Rockbox Development Builds");

#my $beware = "<p style='color:#800; border: 5px solid red; margin: 10px; padding: 5px;'><big>Right now is such a time. These builds <b>do not work</b>! Please don't download until the devs have solved the problem (and removed this text).</big>";

print <<HEAD
<p>
 These builds are updated <b>every</b> source code change, and the links 
 always point at the most recent successful build for a given player.
<p>
 Since these builds are generated from actively developed source, at times
 they may be buggy or even unusable.
<p>
 Please note that targets/builds we consider <i>unusable</i> are not included on this list.
<p>
 We appreciate your feedback on any issues you may encounter.

$beware

<p>
 For a stable build, <a href="//www.rockbox.org/download/">download the latest stable release</a>.

<p>
<a href="dev.cgi">Autobuilder details</a> &middot;
<a href="//www.rockbox.org/daily.shtml">Daily snapshot builds and voice files</a>
HEAD
    ;

buildtable();

footer();

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
my $date=sprintf("%04d%02d%02dT%02d%02d%02dZ", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

open(F, ">build-info.new");
print F "[bleeding]\n";
print F "timestamp=\"$date\"\n";
print F "rev=\"$ARGV[0]\"\n";
print F "[development]\n";
print F "build_url=https://build.rockbox.org/data/rockbox-%TARGET%.zip\n";
print F "source_url=https://build.rockbox.org/data/rockbox-source.tar.xz\n";
print F "; No voices currently generated for dev builds\n";
print F "voice_url=https://download.rockbox.org/daily/%TARGET%/voice-%TARGET%-%VERSION%-%LANGUAGE%.zip\n";
print F "manual_url=https://build.rockbox.org/data/rockbox-%TARGET%-%FORMAT%\n";
print F "font_url=https://download.rockbox.org/daily/fonts/rockbox-fonts-%VERSION%.zip\n";

for my $m (usablebuilds()) {
#    print F "$m=$revs{$m},https://build.rockbox.org/data/rockbox-$m.zip\n";
    print F "$m=$revs{$m}\n";
}
close(F);
