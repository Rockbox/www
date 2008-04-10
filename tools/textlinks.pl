#!/usr/bin/perl
use open IN => ':utf8';
use open OUT => ":encoding('iso-8859-1')";

# get text links from xml feed and produce html

my $url = "http://update.livecustomer.net/?key=a539610bf93ee0795156fa7055d4b222&version=2.0.0&include_id=4696";

my @output = `curl --silent --max-time 5 "$url"`;
my $output = join '', @output;

my @lines = split /<Link/i, $output;
my @list;

for my $line (@lines) {
    if ($line =~ /url><!\[cdata\[(.+?)\]/i) {
        my $url = $1;
 
        if ($line =~ /description><!\[cdata\[(.+?)\]/i) {
            push @list, "<a href='$url'>$1</a>";
        }
    }
}

my $html = join ",\n", @list;

print <<END
<p>&nbsp;<p>&nbsp;
<table cellspacing="0" cellpadding="2" width="98" style='border: solid black 1px;'><tr><td style='font-size: 9px;'>
$html
</td></tr></table>
END
    ;
