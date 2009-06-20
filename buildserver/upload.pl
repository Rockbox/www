#!/usr/bin/perl

use CGI 'param';
use File::Copy;
use File::Basename;

my $cwd = dirname $0;
my $cgi = basename $0;

my $filename = param("upfile");
my $tmpfile = CGI::tmpFileName($filename);

$filename =~ s/[\;\:\!\?\*\"\'\,\ ]/_/g;

print "Content-type: text/plain\n";

#for (param()) {
#    printf "$_: %s\n", param($_);
#}
#exit;

if (-f "$cwd/$filename") {
    print "Status: 403 Cannot overwrite file\n";
    exit;
}

if (move($tmpfile, "$cwd/$filename")) {
    print "Status: 200 Upload successful\n";
}
else {
    print "Status: 502 Move failed\n";
}

print "\n$cwd/$filename\n";
print STDERR "\n$cwd/$filename\n";
