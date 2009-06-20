#!/usr/bin/perl

use CGI 'param';
use File::Copy;
use File::Basename;

my $cwd = dirname $0;
my $cgi = basename $0;

my $filename = param("upfile");
my $tmpfile = CGI::tmpFileName($filename);

$filename =~ s/[\;\:\!\?\*\"\'\,\ ]/_/g;
if (move($tmpfile, "$cwd/$filename")) {
    print "200 Upload successful\n";
}
else {
    print "502 Move failed\n";
}

