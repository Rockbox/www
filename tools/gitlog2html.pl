#!/usr/bin/perl

use POSIX;
use Encode::Encoder;

require 'nicedate.pm';

my @mname = ('January', 'February', 'March', 'April', 'May',
             'June', 'July', 'August', 'September', 'October',
             'November', 'December' );

my %action;

my %skip_tags = ('Change-Id' => 1,
                 'git-svn-id' => 1);

sub file2url {
    my ($file, $rev)=@_;
    my $sfile = $file;
    my $urlroot="http://git.rockbox.org/?p=rockbox.git";
    $sfile =~ s:^/trunk::;
    $sfile =~ s:^/::;

    my $diff;
    my $a = $action{$file};

    my $path = sprintf("<a class=\"fname\" href=\"$urlroot;a=blob;f=%s\">%s</a>",
                       $file, $sfile);

    if($a eq "R") {
        $diff = " [<span class=\"fname\">rename</span>]";
    }
    elsif($a eq "M") {
        $diff = " [<a class=\"fname\" href=\"$urlroot;a=commitdiff;h=$rev\">diff</a>]";
    }
    elsif($a eq "A") {
        $diff = " [<span class=\"fname\">new</span>]";
    }
    elsif($a eq "D") {
        $diff = " [<span class=\"fname\">deleted</span>]";
    }

    return "$path $diff\n";
}

print "<table class=\"changetable_front\"><tr><th>when</th><th>what</th><th>where</th><th>who</th></tr>\n";

my $when;
my $where;
my $who;
my $whoshort;
my $what;
my $manyfiles = 0;
my $hash;

my @b;
my @f;
my $rev;

# example:

# commit e4af358
# Author: Peter Lecky <lecky_lists@nextra.sk>
# Date:   2012-01-10 00:06:02 -0500
# 
#     FS#12516 - Slovak lang update
#     
#     Change-Id: I4bca90cd3d757ff37f616f47c41dd78537db6a80
#     Signed-off-by: Rafaël Carré <funman@videolan.org>
# 
# M       apps/lang/slovak.lang

while(<STDIN>) {
    my $l = $_;
    chomp $l;

    if (/^commit (\w+)/)
    {
        my $tmp = $1;
        if($b[0] || $f[0]) {
            if (scalar @f > 30) {
                $manyfiles = scalar(@f) - 30;
                @f = @f[0 .. 29];
            }
            for(@f) {
                $where .= sprintf("%s<br>", file2url($_, $hash));
            }
            if ($manyfiles) {
                $where .= "...and $manyfiles more files.";
            }
            if (1) {
                my $br;
                $what = "<small><a href='http://git.rockbox.org/?p=rockbox.git;a=commit;h=$hash'>$hash</a>:</small> ";
                while ($b[$#b] eq "\n") {
                    delete $b[$#b];
                }

                for my $l (@b) {
                    $l =~ s:&:&amp;:g;
                    $l =~ s:<:&lt;:g;
                    $l =~ s:>:&gt;:g;
                    $l =~ s!FS *\#(\d+)!<a href=\"http://www.rockbox.org/tracker/task/$1\">FS \#$1</a>!g;
                    $l =~ s!\#(\d{4,})!<a href=\"http://www.rockbox.org/tracker/task/$1\">\#$1</a>!g;
                    $what .= "<br>" if($br);
                    $what .= $l;
                    $br++;
                }
            }
            print "<tr><td nowrap class=\"cstamp\">$when</td>\n",
            "<td class=\"cdesc\">$what</td>\n",
            "<td nowrap class=\"cpath\">$where</td>\n",
            "<td class=\"cname\">$who</td>\n",
            "</tr>\n";
            $when = $where = $what = $who = $whoshort = $manyfiles = "";
        }
        $hash = $tmp;
        next;
    }
    elsif (/^Author: ([^<]+)/)
    {
        $who = $1;
    }
    elsif (/^Date: (.+)/) 
    {
        my $date = $1;
        if($date =~ /(\d\d\d\d)-(\d\d)-(\d\d)/) {
            my ($yr,$mt,$dy) = ($1,$2,$3);
            if ($date =~ /(\d\d):(\d\d):(\d\d)/) {
                my $t = mktime($3,$2,$1,$dy,$mt-1,$yr-1900);
                $when = &reltime($t);
            }
        }

        undef @b;
        undef @f;
        undef %action;
    }
    elsif (/^([ACDMRTYXB])\s+(.+)/)
    {
        # file
        $action{$2}=$1;
        push @f, $2;
    }
    else {
        my $skip = 0;
        if (/\w/ || @b) {
            if (/^\s*(.+?):/)
            {
                $skip = 1 if (defined $skip_tags{$1});
            }
            $l =~ s/\<.+//g; # remove email address
            push @b, "$l\n" unless ($skip);
        }
    }
}

print "</table>\n";
