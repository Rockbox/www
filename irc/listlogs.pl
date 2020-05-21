#!/usr/bin/perl

my $base = "logs/";

open FLIST, "-|", "find $base -name 'rockbox*.txt'" or
  die "Can't execute find: $!";

my @logs;

while (<FLIST>) {
  chomp;
  s/$base(.*)/$1/;
  push @logs, $_;
}

close DIR;

print "Content-type: text/html\n\n<html><body>\n";

foreach (reverse sort @logs) {
    /(\d\d\d\d)(\d\d)(\d\d)/;
    print "<a href='//download.rockbox.org/irc-logs/$_'>$1-$2-$3</a><br>\n";
}

print "</body></html>\n";
