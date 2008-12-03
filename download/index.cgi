#!/usr/bin/perl

require "../rockbox.pm";
require "table.pm";

header("Rockbox 3.0");

print <<HEAD
<p>
Rockbox 3.0 was released on September 23, 2008. Three years after the previous
release! See the full <a href="/twiki/bin/view/Main/ReleaseNotes30">Release Notes</a>
<p>
Update: the Archos models got a 3.0.1 release on October 21. See the <a href="/twiki/bin/view/Main/ReleaseNotes301">3.0.1 Release Notes</a>

<h2>Option 1: Automatic install</h2>
<p>Download and run the <a href="/twiki/bin/view/Main/RockboxUtility">Rockbox Utility</a>.

<h2>Option 2: Manual install</h2>
<p>Download the zip for your target and unzip it to your device.
HEAD
    ;

buildtable();

print <<HEAD
<p> <a href="http://download.rockbox.org/old_releases/">old releases</a>
archive.

HEAD
    ;

footer();
