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

my $destpath="$cwd/upload";

if (-f "$destpath/$filename") {
    print "Status: 403 Cannot overwrite file\n";
    exit;
}

if (move($tmpfile, "$destpath/$filename")) {
    chmod 0660, "$destpath/$filename"; # chmod ug+rw
    print "Status: 200 Upload successful\n";
}
else {
    print "Status: 502 Move failed: $!\n";
}

print "\n$destpath/$filename\n";
print STDERR "\n$destpath/$filename\n";
