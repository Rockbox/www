#!/usr/bin/perl

use lib '.';
require "../rockbox.pm";
require "table.pm";

header("Rockbox Manual Installation");

print <<HEAD
<p>
Rockbox $publicrelease was released on ${releasedate}. See the full 
<a href="$releasenotes">Release Notes</a> for further details.

<p>We recommend using the <a href="/wiki/RockboxUtility">Rockbox 
Utility</a> to install Rockbox, but if you insist you can do it 
manually.  Please see the per-target installation instructions in the 
corresponding manual.</p>

<p>Download the <i>Firmware</i> zip for your target below and unzip it 
to your device.</p>
<p>We also recommend grabbing the <i>Fonts</i> as well, and a <i>Voice</i> 
pack for voice prompts.  Other languages can be generated via the Rockbox 
Utility.</p>
<p>If you want to peek under the hood get the <i>Source</i> archive.</p>
HEAD
    ;

buildtable();

print <<HEAD
<p> <a href="//download.rockbox.org/release/">Previous releases</a>
archive (3.0 and newer).
<br><a href="//download.rockbox.org/old_releases/">Historical releases</a>
archive (prior to 3.0).

HEAD
    ;

footer();
