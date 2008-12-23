#!/usr/bin/perl

require "../rockbox.pm";
require "table.pm";

header("Rockbox 3.1");

print <<HEAD
<p>
Rockbox 3.1 was released on December 23, 2008. See the full <a href="/twiki/bin/view/Main/ReleaseNotes31">Release Notes</a>

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
