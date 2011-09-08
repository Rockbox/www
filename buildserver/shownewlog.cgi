#!/usr/bin/perl

require "CGI.pm";

$req = new CGI;

$rev = $req->param('rev');
$rev =~ s/[^\w]//g;
$type = $req->param('type');
$type =~ s/[^\w]//g;

print "Content-Type: text/html\n\n";

print <<MOO
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
<link rel="STYLESHEET" type="text/css" href="http://www.rockbox.org/style.css">
<title>Rockbox: $type $rev</title>
<meta name="author" content="Daniel Stenberg, in perl">
</head>
<body bgcolor="#b6c6e5" text="black" link="blue" vlink="purple" alink="red"
      topmargin=3 leftmargin=4 marginwidth=4 marginheight=4>
MOO
    ;


print "<h1>$type, revision $rev</h1>\n";

my @o;
my $prob;
my $lserver;
my $buildtime;

open(LOG, "<data/$rev-$type.log") or
    die "Failed opening log: $!";
while (<LOG>) {
    if (/^Build Time: (\d+)/) {
        $buildtime = $1;
    }
    elsif (/^Build Client: (.*)/) {
        $lserver = $1;
        $match = 1;
        push @o, "<div class=\"gccoutput\">";
    }
    elsif ($match) {
        if($_  =~ /^Build Status:/) {
            $match=0;
        }
        else {
            my $class="";
            $_ =~ s:/home/dast/rockbox-auto/::g;
            $line = $_;
            chomp $line;

            if($lserver) {
                push @o, "<h2>Built by <b>$lserver</b></h2>";
                $lserver="";
            }

            if($line =~ /^([^:]*):(\d*):.*warning:/) {
                $prob++;
                push @o, "<a name=\"prob$prob\"></a>\n";
                push @o, "<div class=\"gccwarn\">$line</div>\n";
            }
            elsif ($line =~ /^([^:]*):(\d*):.*note: (.*)/)
            {
                # some gcc versions like to print notes every now and then
                # we'll ignore those
                push @o, "$line\n<br>\n";
            }
            elsif (($line =~ /^(([^:]*):(\d+):| *make: *\*\*\*)/) or
                   ($line =~ /(: undefined reference to|ld returned (\d+) exit status|gcc: .*: No such file or)/)
#                  or ($line =~ /^error:/)
                   ) {
                $prob++;
                push @o, "<a name=\"prob$prob\"></a>\n";
                push @o, "<div class=\"gccerror\">$line</div>\n";
            }
            else {
                push @o, "$line\n<br>\n";
            }
        }
    }
}
close(LOG);

if($prob) {
    print "Goto problem: ";
    my $p;
    foreach $p (1 .. $prob) {
        print "<a href=\"#prob$p\">$p</a>\n";
        if($p == 5) {
            last;
        }
    }
    if($prob > 5 ) {
        print "... <a href=\"#prob$prob\">last</a>\n";
    }

    print "<p>\n";
}

print @o;

print "</div></body></html>\n";
