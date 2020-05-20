#!/usr/bin/perl

use lib '.';
require "../rockbox.pm";
require "table.pm";

header("Rockbox Manual Install");

print <<HEAD
<p>
Rockbox $publicrelease was released on ${releasedate}. See the full <a href="$releasenotes">Release Notes</a>

<p> We recommend using <a href="/twiki/bin/view/Main/RockboxUtility">Rockbox
Utility</a> to install Rockbox, but if you insist you can do it manully.

<p>Download the <i>Firmware</i> zip for your target below and unzip it to your device.
<p>We also recommend grabbing the <i>Fonts</i> as well, and the <i>Voice</i> pack for english voice prompts.  Other languages can be generated via the Rockbox Utility.
<p>If you want to peek under the hood get the <i>Source</i> archive.
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
