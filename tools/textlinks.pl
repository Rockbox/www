#!/usr/bin/perl
use open IN => ':utf8';
use open OUT => ":encoding('iso-8859-1')";

# get text links from xml feed and produce html

my $file = $ARGV[0];

my $url = "http://update.livecustomer.net/?key=a539610bf93ee0795156fa7055d4b222&version=2.0.0&include_id=4696";

my @output = `curl --silent --max-time 60 "$url" -z $file`;
my $output = join '', @output;
exit if (length $output < 10);

my @lines = split /<Link/i, $output;
my @list;

for my $line (@lines) {
    if ($line =~ /url><!\[cdata\[(.+?)\]/i) {
        my $url = $1;
 
        if ($line =~ /description><!\[cdata\[(.+?)\]/i) {
            my $desc = $1;
            $desc =~ s/\x{2019}/\'/g; # OUT encoding doesn't handle this
            push @list, "<a href='$url'>$desc</a>";
        }
    }
}

my $html = join ",\n", @list;

open(FILE, ">:encoding(UTF-8)", $file) or
    die "Failed opening $file for writing: $!";
print FILE <<END
<p>&nbsp;<p>&nbsp;<p>&nbsp;<p>&nbsp;<p>&nbsp;<p>&nbsp;
<p style='margin: 0 0 0 1px;'><img src='tlinkhead.gif' width=20 height=13>
<table cellspacing="0" cellpadding="2" width="98" style='border: solid black 1px;'><tr><td style='font-size: 9px; font-family: arial, helvetica, sans-serif;'>
$html
</td></tr></table>
END
    ;

close FILE;
