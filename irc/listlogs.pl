#!/usr/bin/perl

opendir DIR, "logs" or
    die "Can't opendir(): $!";
my @logs = grep { /^rockbox-/ } readdir(DIR);
closedir DIR;

print "Content-type: text/html\n\n<html><body>\n";

foreach (reverse sort @logs) {
    /(\d\d\d\d)(\d\d)(\d\d)/;
    print "<a href='//download.rockbox.org/irc-logs/$_'>$1-$2-$3</a><br>\n";
}

print "</body></html>\n";
