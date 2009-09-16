#!/usr/bin/perl

my $basedir = "/home/dast/rockbox-build/daily-build/changelogs";

print "Content-type: text/html\n\n";

opendir(DIR, $basedir) or die "Can't opendir $basedir";
my @ch = sort grep { /^changes-/ } readdir(DIR);
closedir DIR;

for ( sort {$b cmp $a} @ch ) {
    my $date = $_;
    $date =~ s/[^0-9]//g;
    if ( -f "$basedir/changes-$date.html") {
        $log = "<a href=\"daily/changelogs/changes-$date.html\">Changes done $date</a>";
    }
    print "$log\n";
    last;
}
