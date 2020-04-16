#!/usr/bin/perl

my $mailfile = "/tmp/blamemail$$";

my @blame = `./seered.pl`;   

if($blame[0]) {
    open FILE, ">$mailfile" or die "Failed creating $mailfile";
    print FILE "The builds are now red thanks to these fine hacker(s):\n\n";

    for(@blame) {
        print FILE $_;
    }
    print FILE "\nThe entire thing of course visible here: ";
    print FILE "//build.rockbox.org/dev.cgi\n";
    close FILE;

    my $cmd = "metasend -b -F tracker\@rockbox.org -s \"Rockbox Blame Game\" -t rockbox-cvs\@cool.haxx.se -f $mailfile -m text/plain -e 8bit";
#print "$cmd\n";
    system($cmd);
    unlink $mailfile;
}
