#!/usr/bin/perl

open(B, "<output/index.html") ||
    die "can't open table";

while(<B>) {
    if($_ =~ /^<td nowrap><a class=\"bstamp\" href=\"([^\"]*)\"/) {
        if($chlog) {
            # this is the second table row, get out!
            last;
        }
        $chlog = $1;
    }
    elsif($_ =~ /^<td class=\"buildfail\"/) {
        # a failure means red, this means we're in business to start BLAMING

        # translate path name to local file name
        $chlog =~ s/cvsmod/output/;

        open(CH, "<$chlog");
        my %blame;
        while(<CH>) {
            if($_ =~ /class=\"cname\">([^<]*)</) {
                $blame{$1}++;
                $cname=$1;
            }
            elsif($_ =~ /class=\"cshortname\">([^<]*)</) {
                # the long name $cname is the svn user $1
                $short{$cname}=$1;
            }
        }
        close(CH);
        for(keys %blame) {
            printf("%s (%s), %d commit%s\n", $_, $short{$_}, $blame{$_},
                   $blame{$_}>1?"s":"");
        }
        last;
    }
}
close(B);
