#!/usr/bin/perl
#
# reader.pl - reads irc logs from the Dancer bot and produces pretty HTML
#
# Copyright 2007 Björn Stenberg <bjorn@haxx.se>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

use CGI 'escapeHTML', 'param';
use POSIX 'strftime', 'mktime';

# hardcoded log format for dancer irc bot

my $logdir = "/home/rockbox/irc-logs";
my $today = strftime "%Y%m%d", localtime;
my $date = param('date') + 0;
my $year = 0;

if ($date == 0) {
    print "Location: https://www.rockbox.org/irc/log-$today\n\n";
    exit;
}
elsif ($date == $today) {
    $file = "current.txt";
}
else {
    $file = "rockbox-$date.txt";
}

if (open NICKS, "<committers.txt") {
    foreach $line (<NICKS>) {
        if ($line =~ /^([^- ]+)/) {
            $regular{$1} = 1;
            $nicks{$1} = 1;
        }
    }
}

if ($date =~ /(\d\d\d\d)(\d\d)(\d\d)/) {
    $title = "#rockbox $1-$2-$3";
    $year = $1;
}

print "Content-type: text/html\n\n";

print <<END
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
<link rel="STYLESHEET" type="text/css" href="/style.css">
<link rel="STYLESHEET" type="text/css" href="reader.css">
<title>$title</title>
END
    ;

if ($file =~ /[^\w\d\.\-]/) {
    print "<p>$file: Invalid filename\n";
    goto foot;
}

my $realfile;

if ($file eq "current.txt") {
    $realfile = $file;
} else {
    $realfile = "$logdir/$year/$file";
}

if (!open FILE, "<$realfile") {
    print "<p>$realfile: $!  ...\n";
    goto foot;
}
my @lines = <FILE>;

my $tophour = 0;

# pass 1: find all nicks
foreach my $line (@lines) {
    chomp $line;
    if ($line =~ /^\d\d\.\d\d.\d\d \# + <([^>]+)> /) {
        $nicks{$1} = 1;
    }
    elsif ($line =~ /^\d\d\.\d\d.\d\d (Join|Part|Quit) + ([^ \[]+)/) {
        $nicks{$2} = 1;
    }

    if ($line =~ m/^(\d\d)\./) {
        $tophour = $1 if ($1 > $tophour);
    }
}

# create styles for all nicks
print "<style type='text/css'>\n";
foreach my $nick (keys %nicks) {
    next if ($nick =~ /[^\w\d_\-]/);
    my ($r, $g, $b);

    if (0) {
        ($r, $g, $b) = (int(rand 16), int(rand 16), int(rand 16));
    }
    else {
        my $len = length $nick;
        $r = (ord substr($nick,0,1)) & 15;
        $g = (ord substr($nick,$len/2,1)) & 7;
        $b = (ord substr($nick,$len-1,1)) & 15;
    }

    if (0) {
        my $zap = ord(substr($nick,0,1)) & 2;
        if ($zap == 0) { $r = 0 }
        elsif ($zap == 1) { $g = 0 }
        elsif ($zap == 2) { $b = 0 }
    }


    printf(".nick_$nick { color: #%x%x%x }\n", $r, $g, $b);
    printf(".row$nick { }\n");
}
print "</style>\n";

my ($prevday, $nextday, $today);

if ($file eq "current.txt") {
    $prevday = sprintf("<a href='log-%s'>Previous day</a>",
                       strftime "%Y%m%d", localtime(time - 86400));
#    $nextday = sprintf("<a href='log-%s'>Next day</a>",
#                       strftime "%Y%m%d", localtime(time + 86400));
     $nextday  = "<s>Next Day</s>";
}
else {
    $file =~ /(\d\d\d\d)(\d\d)(\d\d)/;
    my ($y, $m, $d) = ($1, $2, $3);
    $prevtime = mktime( 0, 0, 0, $d-1, $m-1, $y-1900);
    $nexttime = mktime( 0, 0, 0, $d+1, $m-1, $y-1900);

    $prevday = sprintf("<a href='log-%s'>Previous day</a>",
                       strftime "%Y%m%d", localtime($prevtime));
    $nextday = sprintf("<a href='log-%s'>Next day</a>",
                       strftime "%Y%m%d", localtime($nexttime));
}
$today = sprintf("<a href='log-today'>Today</a>");

my $hourlinks;
foreach (1 .. $tophour) {
    $hourlinks .= sprintf "<a href='#%02d:00'>%02d</a> ", $_, $_;
}

my $jstime = (stat("reader.js"))[9];

print <<END
</head>
<body bgcolor="#b6c6e5" text="black" link="blue" vlink="purple" alink="red">
<script src='reader.js?$jstime' language='javascript' type='text/javascript'></script>

<table class=options>
<tr><td>$prevday | Jump to hour: $hourlinks | $nextday | $today
<p>
Seconds: 
<a href="javascript:seconds(1);">Show</a>
<a href="javascript:seconds(0);">Hide</a>

| Joins:
<a href="javascript:joins(1);">Show</a>
<a href="javascript:joins(0);">Hide</a>

| <a href="//www.rockbox.org/irc/logs/$year/$file">View raw</a>

<br>Font:
<a href="javascript:font('serif');"><span style='font-family: serif'>Serif</span></a>
<a href="javascript:font('sans-serif');"><span style='font-family: sans-serif'>Sans-Serif</span></a>
<a href="javascript:font('monospace');"><span style='font-family: monospace'>Monospace</span></a>

| Size:
<a href="javascript:fontsize('90%');"><span style='font-size: 90%'>Small</span></a>
<a href="javascript:fontsize('100%');">Medium</a>
<a href="javascript:fontsize('120%');"><span style='font-size: 120%'>Large</span></a>

<p>Click in the nick column to <span style='background-color: yellow'>highlight</span> everything a person has said.
<br>The <img align='bottom' src='/rockbox16.png' alt='Logo'> icon identifies that the person is a core developer (has commit access).
</td>
</tr>
</table>

END
    ;

$date =~ m/(\d\d\d\d)(\d\d)(\d\d)/;
print "<h2>#rockbox log for $1-$2-$3</h2>\n";

my $lasthour = 0;
my $houranchor;

print "<table class=irclog>\n";
# pass 2: output html

&parsechunk(\@lines);

close FILE;
print "</table>\n";
foot:

print <<END
<p>$prevday | $nextday | $today
</body>
</html>
END
    ;

sub parsechunk {
    my $lines = shift @_;
    foreach my $line (@{$lines}) {
        next unless ($line =~ /^(\d\d)\.(\d\d).(\d\d) ([^ ]+) +(.*)/);

        my ($hour, $minute, $second, $action, $string) = 
            ($1, $2, $3, $4, $5);

        last if ($hour > 0 and param('test'));

#        print "$line";

        if ($hour > $lasthour) {
            printf "<tr><td class=hourbar colspan=3><a name='%02d:00' href='#%02d:00'>%02d:00</a></td></tr>\n", $hour, $hour, $hour;
            $lasthour = $hour;
        }

# This seems to be intended to strip out control characters
# but ropes in other stuff too...
#        $string =~ s|[-]||g;

        if ($action eq "#") {
            my ($nick, $message);
            if ($string =~ /^<([^>]+)> (.*)/) {
                ($nick, $message) = ($1, $2);
            }
            elsif ($string =~ /^\* (.*)/) {
                $nick = "*";
                $message = $1;
            }
            $message = escapeHTML($message);

            # tag URLs
            if ($message =~ m!((http|https|ftp)://[^\)\s,]+)!) {
                my $url = $1;
                my $showurl = $url;
                $showurl =~ s|([/&])|<wbr>$1|g;
                $message =~ s|\Q$url\E|<a target="_blank" href="$url">$showurl</a>|;
            }

            # tag flyspray
            $message =~ s!FS *\#(\d+)!<a target="_blank" href=\"https://www.rockbox.org/tracker/task/$1\">FS \#$1</a>!g;
            $message =~ s!fs*\#(\d+)!<a target="_blank" href=\"https://www.rockbox.org/tracker/task/$1\">fs\#$1</a>!g;

            # tag git revisions (WIP)
            $message =~ s!Revision (\w+)(\b)!<a target="_blank" href=\"https://git.rockbox.org/cgit/rockbox.git/commit/?id=$1\">Revision $1</a>$3!g;

            # tag gerrit ids
            $message =~ s!\s*g\#(\d+)! <a target="_blank" href=\"https://gerrit.rockbox.org/r/c/rockbox/+/$1\">g\#$1</a>!g;

            # escape text that looks like the multipart delimiter
            $message =~ s!--!&minus;&minus;!g;

            # break long lines. max 60 chars
            if (0 and $message =~ /([^ ]{60,})/) {
                my $substr_orig = $1;
                my $substr = $1;
                unless ($substr =~ s/,([^ ])/, $1/g) {
                    unless ($substr =~ s/\.([^ ])/\. $1/g) {
                        unless ($substr =~ s/-([^ ])/- $1/) {
                            unless ($substr =~ s|/([^ ])|/ $1|) {
                            }
                        }
                    }
                }
                $message =~ s/\Q$substr_orig\E/$substr/;
                #print STDERR "wrapped: $substr_orig ==> $substr\n";
            }

            # tag all nicks
            foreach my $nick (keys %nicks) {
                if (index($message, $nick) > -1) {
                    $message =~ s|\b\Q$nick\E\b|<span class='nick_$nick'>$nick</span>|g;
                }
            }

            # remove color codes
            $message =~ s|\x03\d+||g;

            # remove control codes
            $message =~ s|[\x00-\x1f]||g;

            # remove any nick-highlightning inside hrefs
            if ($message =~ /href=\"([^\"]+)/) {
                my $url = $1;
                my $broken_url = $url;
                if ($url =~ /<span class='nick_([^>]+)'/) {
                    my $nick = $1;
                    $url =~ s|<span class='nick_$nick'>$nick</span>|$nick|g;
                    $message =~ s|$broken_url|$url|g;
                }
            }

            my $class = "nick";
            my $realnick = $nick;
            if (defined $regular{lc $nick}) {
                $class = "regular";
            }
            elsif (($nick eq "*") and ($message =~ /^<span class="nick_([^>]+)/)) {
                $realnick = $1;
                if (defined $regular{lc $realnick}) {
                    $class = "regular";
                }
            }
            my $n1 = "<span class=\"nick_$realnick\">";
            my $n2 = "</span>";
            if ($nick =~ /[^\w\d_\-]/) {
                $n1 = $n2 = "";
            }

            print("<tr valign=top class='row$realnick'>",
                  "<td class=time><a name='$hour:$minute:$second' href='$ENV{query}#$hour:$minute:$second'>$hour:$minute",
                  "<span class=seconds>:$second</span></a></td>",
                  "<td class=$class onclick='markNick(\"$realnick\");'>$n1$nick$n2</td>",
                  "<td class=message>$message</td>",
                  "</tr>\n");
            $houranchor = "";
        }
        elsif ($action =~ /^(Join|Quit|Part|Nick)/) {
            my ($nick, $message);
            if ($string =~ /^([^ ]+) *(.*)/) {
                ($nick, $message) = ($1, $2);
                $message = escapeHTML($message); 
            }
            print("<tr class=join valign=top>",
                  "<td class=time>$hour:$minute",
                  "<span class=seconds>:$second</span></td>",
                  "<td>&nbsp;</td>",
                  "<td class=action>$action ",
                  "<span class=\"nick_$nick\">$nick</span> ",
                  "<span class=quitmsg>$message</span></td>",
                  "</tr>\n");
        }
        else {
            print("<tr class=misc valign=top>",
                  "<td class=time>$hour:$minute",
                  "<span class=seconds>:$second</span></td>",
                  "<td class=action>$action</td>",
                  "<td class=string>$string</td>",
                  "</tr>\n");
        }
    }
}
