#!/usr/local/bin/perl

require "CGI.pm";
require "./nicedate.pm";

sub recentwiki
{
    my @array;
    my @ret;
    my $max=$ARGV[0];
    $max = 10 if (!$max);
    my $i;
    my %done;

    open(FILE, "/home/rockbox/foswiki/data/Main/.changes");
    for (<FILE>) {
        my ($subject, $user, $date)=split("\t", $_);
        $data{$date}=$_;
        push @array, $date;
    }
    close(FILE);

    @array=reverse sort {$a <=> $b} @array;

    push @ret, "<table class='twikichanges'>\n";
    push @ret, "<tr><th>when</th><th>what</th><th>who</th></tr>\n";
    for ($i=0; $max>0 && $i<$#array; $i++) {
        my ($subject, $user, $date)=split("\t", $data{$array[$i]});
	next if ($subject =~ /WikiUsers/);
	next if ($subject =~ /Registrations/);

        if (!$done{$subject}) {
            $max--;
            $done{$subject}=1;

            $uname=$user;
            $uname =~ s/ /&nbsp;/g;
            my $ulink="<a href=\"/wiki/".CGI::escape($user)."\">$uname</a>";
            my $link="<a href=\"/wiki/".CGI::escape($subject)."\">$subject</a>";
            push @ret, "<tr><td nowrap>";
            push @ret, reltime($date,1);
            push @ret, "</td>";
            push @ret, "<td>$link</td><td>$ulink</td></tr>\n";
        }
    }
    push @ret, "</table>";

    return @ret;
}

print recentwiki;
