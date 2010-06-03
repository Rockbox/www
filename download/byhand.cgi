#!/usr/bin/perl

require "../rockbox.pm";
require "table.pm";

header("Rockbox Manual Install");

print <<HEAD
<p>
Rockbox $publicrelease was released on ${releasedate}. See the full <a href="$releasenotes">Release Notes</a>

<p> We recommend using <a href="/twiki/bin/view/Main/RockboxUtility">Rockbox
Utility</a> to install Rockbox, but if you insist you can do it manully.

<p>Download the zip for your target below and unzip it to your device.
<br>If this is your first install, you also want the <a href="http://download.rockbox.org/release/3.6/rockbox-fonts-3.6.zip">Font Pack</a>.
<br>If you want to peek under the hood, get the <a href="http://download.rockbox.org/release/3.6/rockbox-3.6.7z">Source archive</a>.
HEAD
    ;

buildtable();

print <<HEAD
<p> <a href="http://download.rockbox.org/release/">Previous releases</a>
archive (3.0 and newer).
<br><a href="http://download.rockbox.org/old_releases/">Historical releases</a>
archive (prior to 3.0).

HEAD
    ;

footer();
