#!/usr/bin/perl

use lib '.';
require "rockbox.pm";

header("Rockbox Autobuilder Details");

print "<script type=\"text/javascript\">\n";
open(TABLE, "<countdown.js");
print <TABLE>;
close(TABLE);
print "</script>\n";

print <<STUFF
<p>
 Build stuff for developers.  All timestamps here are UTC!
</p>
<p>
 <a href="./">Current build page</a>
</p>
STUFF
  ;

print "<p><div id='smalltable'>\n";
open(TABLE, "<builds.html");
print <TABLE>;
close(TABLE);
print "</div>\n";

print "<div id='bigtable' style='display:none'>\n";
open(TABLE, "<builds_all.html");
print <TABLE>;
close(TABLE);
print "</div></p><p><a href='javascript:toggle_table()'>Toggle full/compact build table</a>\n";

print "<a href='javascript:toggle_sizetable()'>Toggle binsize/ramsize table</a></p>\n";

print "<p><div id='ramtable'>\n";
open(TABLE, "<sizes.html");
print <TABLE>;
close(TABLE);
print "</div>\n";

print "<div id='bintable' style='display:none'>\n";
open(TABLE, "<sizes2.html");
print <TABLE>;
close(TABLE);
print "</div></p>\n";

&footer();
