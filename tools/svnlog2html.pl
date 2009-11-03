#!/usr/bin/perl

use POSIX;

require 'nicedate.pm';

my $reldate = 1;
if ($ARGV[0] eq "-absdate") {
    $reldate = 0;
}

# give this script "svn log -v" output

my $s = 0;

my @b;
my @f;
my $rev;

my %shortnames; # hash for nick => full name
sub getshortnames
{
    my ($file)=@_;

    open(NICKS, $file) || die;

    while(<NICKS>) {
        chomp;
        if(/^ *\#/) {
            # we support #-style comments
            next;
        }
        if(/([^ ]*) (.*)/) {
            $shortnames{lc $1}=$2;
        }
    }
    close(NICKS);
}

my @mname = ('January', 'February', 'March', 'April', 'May',
             'June', 'July', 'August', 'September', 'October',
             'November', 'December' );

my %action;

sub file2url {
    my ($file, $rev)=@_;
    my $sfile = $file;
    my $urlroot="http://svn.rockbox.org/viewvc.cgi";
    $sfile =~ s:^/trunk::;
    $sfile =~ s:^/::;

    my $diff;
    my $a = $action{$file};

    if($file =~ s/ *\(from .*:(\d+)\)//) {
        $sfile =~  s/ *\(from .*:(\d+)\)//;
        $a ="R"; # rename
    }

#    my $path = sprintf("<a class=\"fname\" href=\"$urlroot%s?view=log;pathrev=%d\">%s</a>$diff\n",
    my $path = sprintf("<a class=\"fname\" href=\"$urlroot%s?view=log\">%s</a>",
                       $file, $sfile);

    if($a eq "R") {
        $diff = " [<span class=\"fname\">rename</span>]";
    }
    elsif($a eq "M") {
        $diff = sprintf(" [<a class=\"fname\" href=\"$urlroot%s?r1=%d;r2=%d;pathrev=%d\">diff</a>]",
                        $file, $rev-1, $rev, $rev);
    }
    elsif($a eq "A") {
        $diff = " [<span class=\"fname\">new</span>]";
    }
    elsif($a eq "D") {
         $path = sprintf("<a class=\"fname\" href=\"$urlroot%s?view=log;pathrev=%d\">%s</a>$diff\n",
                       $file, $rev-1, $sfile);
        #$path = "<span class=\"fname\">$sfile</span>";
        $diff = " [<span class=\"fname\">deleted</span>]";
    }

    return "$path $diff\n";
}

getshortnames("/sites/rockbox.org/trunk/docs/COMMITTERS");

print "<table class=\"changetable_front\"><tr><th>when</th><th>what</th><th>where</th><th>who</th></tr>\n";

my $when;
my $where;
my $who;
my $whoshort;
my $what;
my $manyfiles = 0;

while(<STDIN>) {
    my $l = $_;
    chomp $l;
    if(/^------------------------------------------------------------------------/) {
        if($b[0] || $f[0]) {
            
            if (scalar @f > 30) {
                $manyfiles = scalar(@f) - 30;
                @f = @f[0 .. 29];
            }
            for(@f) {
                $where .= sprintf("%s<br>", file2url($_, $rev));
            }
            if ($manyfiles) {
                $where .= "...and $manyfiles more files.";
            }
            if (1) {
                my $br;
                $what = "<small><a href='http://svn.rockbox.org/viewvc.cgi?view=rev;revision=$rev'>r$rev</a>:</small> ";
                for my $l (@b) {
                    $l =~ s:&:&amp;:g;
                    $l =~ s:<:&lt;:g;
                    $l =~ s:>:&gt;:g;
                    $l =~ s!FS *\#(\d+)!<a href=\"http://www.rockbox.org/tracker/task/$1\">FS \#$1</a>!g;
                    $l =~ s!\#(\d{4,})!<a href=\"http://www.rockbox.org/tracker/task/$1\">\#$1</a>!g;
                    $l =~ s!r(\d+)!<a href='http://svn.rockbox.org/viewvc.cgi?view=rev;revision=$1'>r$1</a>!g;
                    $what .= "<br>" if($br);
                    $what .= $l;
                    $br++;
                }
            }
            print "<tr><td nowrap class=\"cstamp\">$when</td>\n",
            "<td class=\"cdesc\">$what</td>\n",
            "<td nowrap class=\"cpath\">$where</td>\n",
            "<td class=\"cname\">$who</td>\n",
            "<!-- <td class=\"cshortname\">$whoshort</td> -->\n",
            "</tr>\n";
            $when = $where = $what = $who = $whoshort = $manyfiles = "";
        }
        $s=1;
        next;
    }
    if($s == 1) {
        undef @b;
        undef @f;
        undef %action;
        $rev = -1;
        if($l =~ /^r(\d+) \| (.+) \| ([0-9-]*) ([0-9:]*) (.*) \| (\d+) line/) {
            $rev = $1;
            $whoshort = $2;
            my $lname = $shortnames{lc($2)} || $whoshort;
            my $t = $4;
            my $d = $3;

            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                gmtime();

            if ($reldate) {
                if($d =~ /(\d\d\d\d)-(\d\d)-(\d\d)/) {
                    my ($yr,$mt,$dy) = ($1,$2,$3);
                    if ($t =~ /^(\d\d):(\d\d):(\d\d)/) {
                        my $t = mktime($3,$2,$1,$dy,$mt-1,$yr-1900);
                        $d = &reltime($t);
                    }
                }
                $when = $d;
            }
            else {
                # absdate
                if ($t =~ /^(\d\d):(\d\d):(\d\d)/) {
                    $when = "$d $1:$2";
                }
            }
            $who = $lname;
        }
        $s++;
    }
    elsif($s == 2) {
        # "Changed paths:"
        $s++;
    }
    elsif($s == 3) {
        if ($l =~ /^   (.) (.*)/) {
            # a file path
            push @f, $2;
            $action{$2}=$1;
        }
        else {
            # end of file names
            $s = 4;
        }
    }
    else {
        push @b, "$l\n"; 
    }
}

print "</table>\n";
