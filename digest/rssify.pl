#!/usr/bin/perl

my $fill = "RRREEEPPP";

my $end++;

while(<STDIN>) {
    my $line = $_;

#    $line =~ s/ZAGOR/Bj�rn Stenberg/g;

    $line =~ s/�/\&Ouml;/g;
    $line =~ s/�/\&ouml;/g;
    $line =~ s/</\&lt;/g;
    $line =~ s/>/\&gt;/g;

    if($line =~ s/(LINK\((\"([^\"]*)\"))/$fill/) {
        my $url = $2;
        $url =~ s/@/\#%40;/g;
        $url =~ s/=/\#%3D;/g;
        $url =~ s/&/\&amp;/g;
        $line =~ s/$fill/LINK\($url/;
    }
    print $line;

    if($line =~ /^ *ENDDATE/) {
        if($end++ == 15) {
            last;
        }

    }
}
