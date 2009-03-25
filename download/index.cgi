#!/usr/bin/perl

require "../rockbox.pm";
require "table.pm";

header("Rockbox $publicrelease Download");

print <<HEAD
<p>
Rockbox $publicrelease was released on ${releasedate}. See the full <a href="$releasenotes">Release Notes</a>

<h2>Option 1: Automatic install</h2>
<big>
<p>Download and run the <a href="/twiki/bin/view/Main/RockboxUtility">Rockbox Utility</a>.
</big>

<h2>Option 2: Manual install</h2>

<p> If you truly want to, you can still do the install <a href="byhand.cgi">manually</a>

<p> <a href="http://download.rockbox.org/old_releases/">old releases</a>
archive.

HEAD
    ;

footer();
