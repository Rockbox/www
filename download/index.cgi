#!/usr/bin/perl

use lib '.';
use lib '..';
require "../rockbox.pm";
require "table.pm";

header("Rockbox $publicrelease Download");

print <<HEAD
<p>
Rockbox $publicrelease was released on ${releasedate}. See the full <a href="$releasenotes">Release Notes</a>

<h2>Option 1: Automatic install</h2>
<p>
<a title="Download Installer" href="/wiki/RockboxUtility#Download"><img border="0" src="download-installer.png" width="248" height="110" alt="Download Installer"></a>

<p>Download and run the <a href="/wiki/RockboxUtility">Rockbox Utility</a>.

<p><B>NOTE:  You MUST use the <a href="https://www.rockbox.org/wiki/AIGOErosQK#Manual_Native_Port_Installation_40update_files_45_the_preferred_way_41">manual installation</a> method for the ErosQ, ErosK, Hifiwalker H2, and Surfans F20.  A future Rockbox Utility release will correct this.</b></p>

<h2>Option 2: Manual install</h2>

<p> If you truly want to, you can still do the install <a href="byhand.cgi">manually</a>

<p> <a href="http://download.rockbox.org/release/">old releases</a>
archive.

HEAD
    ;

footer();
