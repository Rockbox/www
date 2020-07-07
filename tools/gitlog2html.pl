#!/usr/bin/perl

use POSIX;
use Encode::Encoder;

require './nicedate.pm';

my @mname = ('January', 'February', 'March', 'April', 'May',
             'June', 'July', 'August', 'September', 'October',
             'November', 'December' );

my %skip_tags = ('Change-Id' => 1,
                 'git-svn-id' => 1,
                 'Reviewed-on' => 1,
                 'Reviewed-by' => 1);

my $urlroot="//git.rockbox.org/cgit/rockbox.git";

sub file2url {
    my ($file, $a, $i, $rev)=@_;
    my $sfile = $file;
    $sfile =~ s:^/trunk::;
    $sfile =~ s:^/::;

    my $diff;
    my $path = sprintf("<a class=\"fname\" href=\"$urlroot/tree/$sfile?id=$rev\">%s</a>",
                       $file, $sfile);

    if($a eq "R") {
        $diff = "rename";
    }
    elsif($a eq "M") {
        $diff = "diff";
    }
    elsif($a eq "A") {
        $diff = "new";
    }
    elsif($a eq "D") {
        $diff = "deleted";
    }

    return "$path [<a class=\"fname\" href=\"$urlroot/diff/$sfile?id=$rev\">$diff</a>]\n";
}

sub dumpoutput {
    my ($h, $when, $what, $who, $gerrit_url, $files, $text) = @_;
    my @f = @$files;
    my @b = @$text;
    my $manyfiles = 0;
    my $where = '';

            if (scalar @f > 30) {
                $manyfiles = scalar(@f) - 30;
                @f = @f[0 .. 29];
            }
            for (@f) {
                my ($file, $action, $i) = @$_;
                $where .= sprintf("%s<br>", file2url($file, $action, $i, $h));
            }
            if ($manyfiles) {
                $where .= "...and $manyfiles more files.";
            }
            if (1) {
                my $br;
                my $g = '';
                $g = " <a href=\"$gerrit_url\">G#$gerrit_id</a>" if ($gerrit_id);
                $what = "<small><a href='$urlroot/diff/?id=$h'>$h</a>$g:</small> ";
                while ($b[$#b] eq "\n") {
                    delete $b[$#b];
                }

                for my $l (@b) {
                    $l =~ s:^\s*::;
                    $l =~ s:&:&amp;:g;
                    $l =~ s:<:&lt;:g;
                    $l =~ s:>:&gt;:g;
                    $l =~ s!FS *\#(\d+)!<a href=\"//www.rockbox.org/tracker/task/$1\">FS \#$1</a>!g;
                    $l =~ s!\#(\d{4,})!<a href=\"//www.rockbox.org/tracker/task/$1\">\#$1</a>!g;
                    $what .= "<br>" if($br);
                    $what .= $l;
                    $br++;
                }

                # pull paragraphs together
                $what =~ s/\n<br>(\w)/ $1/g;
            }
            print "<tr><td nowrap class=\"cstamp\">$when</td>\n",
            "<td class=\"cdesc\">$what</td>\n",
            "<td nowrap class=\"cpath\">$where</td>\n",
            "<td class=\"cname\">$who</td>\n",
            "</tr>\n";
}

print "<table class=\"changetable_front\"><tr><th>when</th><th>what</th><th>where</th><th>who</th></tr>\n";

my $when;
my $who;
my $what;
my $hash;
my $gerrit_url = '';
my $gerrit_id;

my @b;
my @f;
my $rev;
my $count = 0;

# example:

#commit a686dbfaa4
#Author:     Dominik Riebeling <Dominik.Riebeling@gmail.com>
#AuthorDate: 2019-11-01 12:32:27 +0100
#Commit:     Dominik Riebeling <Dominik.Riebeling@gmail.com>
#CommitDate: 2020-06-21 09:07:17 +0200
#
#    sbtools: Avoid calling pkg-config on each compiler invocation.
#    
#    Only expand pkg-config calls once by making the compiler flags simply
#    expanded variables. Makes things more predicable and slightly faster.
#    
#    Change-Id: Ie2ed066f205a95ec8a7708cefeb29e9989815db6
#
#M       utils/imxtools/sbtools/Makefile

while(<STDIN>) {
    chomp;

    if (/^commit (\w+)/)
    {
        if($b[0] || $f[0]) {
            dumpoutput($hash, $when, $what, $who, $gerrit_url, \@f, \@b);
            $when = $what = $who = $gerrit_url = $gerrit_id = "";
        }
        $hash = $1;
        next;
    }
    elsif (/^Author: ([^<]+)/)
    {
        $who = $1;
    }
    elsif (/^CommitDate: (.+)/)
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
        $count = 0;
    }
    elsif (/^([ACDMRTYXB])\s+(.+)/)
    {
        # file
        $count++;
        push (@f, [$2, $1, $count]);
    }
    else {
        my $skip = 0;
        if (/\w/ || @b) {
            if (/^\s*(.+?):/)
            {
                $skip = 1 if (defined $skip_tags{$1});
                if (/Reviewed-on: (.*)/) {
                    $gerrit_url = $1;
                    if ($gerrit_url =~ /(\d+)/) {
                        $gerrit_id = $1;
                    }
                }
            }
            $_ =~ s/<.+@.+>//g; # remove email addresses
            push @b, "$_\n" unless ($skip);
        }
    }
}

if($b[0] || $f[0]) {
     dumpoutput($hash, $when, $what, $who, $gerrit_url, \@f, \@b);
}

print "</table>\n";
