#!/usr/bin/perl

use lib '.';
require "/home/rockbox/www/rockbox.pm";
require "table.pm";

header("Rockbox $publicrelease Download");

print <<HEAD
<p>
Rockbox $publicrelease was released on ${releasedate}. See the full <a href="$releasenotes">Release Notes</a>

<h2>Option 1: Automatic install</h2>
<p>
<a title="Download Installer" href="/twiki/bin/view/Main/RockboxUtility#Download"><img border="0" src="download-installer.png" width="248" height="110" alt="Download Installer"></a>

<p>Download and run the <a href="/twiki/bin/view/Main/RockboxUtility">Rockbox Utility</a>.

<h2>Option 2: Manual install</h2>

<p> If you truly want to, you can still do the install <a href="byhand.cgi">manually</a>

<p> <a href="http://download.rockbox.org/release/">old releases</a>
archive.

HEAD
    ;

footer();
