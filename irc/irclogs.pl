#!/usr/bin/perl

require "../date.pm";

my $logdir = "/home/rockbox/download/irc-logs";

opendir(DIR, $logdir) or
    die "Can't opendir()";
@logs = grep { /^rockbox-/ } readdir(DIR);
closedir DIR;

print "Content-type: text/html\n\n";
print "<table class=archive>\n";

my %y;
my %ym;
my %ymd;
for (@logs) {
    /(\d\d\d\d)(\d\d)(\d\d)/;
    $y{$1}++;
    $ym{$1.$2}++;
    $ymd{$1.$2.$3}++;
}

for (reverse sort keys %y) {
    my $y =$_;
    # print "Y: $y => \n";
    foreach my $i (0 .. 11) {
        my $m= 12-$i;
        my $zp = sprintf("%02d", $m);
        if(!$ym{$y.$zp}) {
            next;
        }
        my $mname = ucfirst substr(MonthNameEng($m), 0, 3);
        print "<tr><th>$mname $y</th>\n";
        foreach my $d ( 1 .. MonthLen($m, $y)) {
            my $zpd = sprintf("%02d", $d);
            if(!$ymd{$y.$zp.$zpd}) {
                print "<td>&nbsp;</td>";
            }
            else {
                #print "<td><a href=\"rockbox-$y$zp$zpd.txt\">$zpd</a></td>";
                #print "<td><a href=\"reader.pl?date=$y$zp$zpd\">$zpd</a></td>";
                print "<td><a href=\"log-$y$zp$zpd\">$zpd</a></td>";
            }
        }
        print "</tr>\n";
    }
}
print "</table>\n";
