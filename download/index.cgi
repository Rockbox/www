#!/usr/bin/perl

require "../rockbox.pm";
require "table.pm";

header("Rockbox 3.0");

print <<HEAD
<p>
Rockbox 3.0 was released on September 23, 2008. Three years after the previous
release!

HEAD
    ;

buildtable();

print <<HEAD
<p> <a href="http://download.rockbox.org/old_releases/">old releases</a>
archive.

HEAD
    ;

footer();
