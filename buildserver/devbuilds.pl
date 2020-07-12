#!/usr/bin/perl

require "../rockbox.pm";
require "./devbuilds.pm";

header_b("Rockbox Development Builds");

#my $beware = "<p style='color:#800; border: 5px solid red; margin: 10px; padding: 5px;'><big>Right now is such a time. These builds <b>do not work</b>! Please don't download until the devs have solved the problem (and removed this text).</big>";

print <<HEAD
<p>
 These builds are provided fresh after <b>every</b> source code change.  If
 builds are not currently showing, wait 5-10 minutes and then refresh the page.
<p>
 Since these builds are generated from actively developed source, at times
 they may be buggy or even unusable. 
 We appreciate your feedback on any issues you may encounter.

$beware

<p>
 For a stable build, <a href="//www.rockbox.org/download/">download the latest stable release</a>.

<p>
<a href="dev.cgi">Autobuilder details</a> &middot; 
<a href="//www.rockbox.org/manual.shtml">Manuals</a> &middot;
<a href="//www.rockbox.org/daily.shtml">Archived developer builds</a>
HEAD
    ;

buildtable();

footer();
