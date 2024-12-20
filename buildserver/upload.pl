#!/usr/bin/perl

use CGI 'param';
use File::Copy;
use File::Basename;
use POSIX qw(strftime);

my $destpath="/var/lib/rbmaster/upload";
my $logfile="/var/lib/rbmaster/upload.log";
sub ulog {
    if (open(L, ">>$logfile")) {
        print L strftime("%F %T ", localtime()) . $_[0] . "\n";
        close(L);
    }
}

my $cwd = dirname $0;
my $cgi = basename $0;

my $filename = param("upfile");
my $fh = CGI::upload("upfile");

$filename =~ s/[\;\:\!\?\*\"\'\,\ \\\/]/_/g;
#print STDERR "Uploading $filename\n";

print "Content-type: text/plain\n";

#for (param()) {
#    printf "$_: %s\n", param($_);
#}
#exit;

if (-f "$destpath/$filename") {
    print "Status: 403 Cannot overwrite file\n";
    exit;
}

my $bytesread = 0;
if (open OUTFILE, ">$destpath/$filename") {
    my ($rval, $buffer);
    while ($rval = read($fh,$buffer,1024)) {
#        print STDERR "read $rval\n";
        $bytesread += $rval;
        print OUTFILE $buffer;
    }
    close OUTFILE;
}
if ($bytesread > 0) {
    print "Status: 200 Upload successful\n";
    ulog "Uploaded upload/$filename ($bytesread)";
} else {
    print "Status: 502 File copy failed: $!\n";
    ulog "Failed creating upload/$filename";
}

print "\n$filename uploaded\n";
#print STDERR "$destpath/$filename\n";
