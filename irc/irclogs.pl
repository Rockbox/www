#!/usr/bin/perl

require "../date.pm";

my $logdir = "/home/rockbox/irc-logs/";

open FLIST, "-|", "find $logdir -name 'rockbox*.txt'" or
  die "Can't execute find: $!";

my @logs;

while (<FLIST>) {
  chomp;
  s/$logdir(.*)/$1/;
  push @logs, $_;
}

close DIR;

my %y;
my %ym;
my %ymd;
for (@logs) {
    /(\d\d\d\d)(\d\d)(\d\d)/;
    $y{$1}++;
    $ym{$1.$2}++;
    $ymd{$1.$2.$3}++;
}

print "Content-type: text/html\n\n";

print "<p>";

for (reverse sort keys %y) {
 my $y =$_;
 print "<a href=\"#${y}\">$y</a> ";
}
print "</p>";

print "<table class=archive>\n";

for (reverse sort keys %y) {
    # print "Y: $y => \n";
    my $y =$_;
    print "<tr><th><a name=\"$y\">$y</a></th></tr>\n";
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
                #print "<td><a href=\"reader.cgi?date=$y$zp$zpd\">$zpd</a></td>";
                print "<td><a href=\"log-$y$zp$zpd\">$zpd</a></td>";
            }
        }
        print "</tr>\n";
    }
}
print "</table>\n";
