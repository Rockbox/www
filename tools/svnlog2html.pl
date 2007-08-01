#!/usr/bin/perl

# give this script "svn log -v" output

my $s = 0;

my @b;
my @f;
my $rev;

# SVN user names, list them in lowercase only
my %shortnames=('linus' => 'Linus Nielsen Feltzing', # Nielsen Feltzing
                'bagder' => 'Daniel Stenberg', # Stenberg
                'zagor' => 'Björn Stenberg', # Stenberg
                'hohensoh' => 'Jörg Hohensohn', # Jörg Hohensohn
                'hardeeps' => 'Hardeep Sidhu', # Hardeep Sidhu
                'learman' => 'Magnus Holmgren', # Magnus Holmgren
                'hbacke' => 'Henrik Backe', # Henrik Backe
                'amiconn' => 'Jens Arnold', # Jens Arnold
                'kjer' => 'Kjell Ericson', # Kjell Ericson
                'midkay' => 'Zakk Roberts', # Zakk Roberts
                'jyp' => 'Jean-Philippe Bernardy', # Jean-Philippe Bernardy
                'quelsaruk' => 'Jose Maria Garcia-Valdecasas Bernal', # Jose Maria Garcia-Valdecasas Bernal
                'christi' => 'Christi Scarborough', # Christi Alice Scarborough
                'matsl' => 'Mats Lidell', # Mats Lidell
                'dave' => 'Dave Chapman', # Dave Chapman
                'christian' => 'Christian Gmeiner', # Christian Gmeiner
                'preglow' => 'Thom Johansen', # Thom Johansen
                'hcl' => 'Michiel Van Der Kolk', #  Michiel Van Der Kolk
                'rasher' => 'Jonas Häggqvist', # Jonas Häggqvist
                'stevenm' => 'Stepan Moskovchenko',
                'tomas' => 'Tomas Salfischberger',
                'pbv' => 'Pedro Vasconcelos', # Vasconcelos
                'miipekk' => 'Miika Pekkarinen', # Miika Pekkarinen
                'bryant' => 'Dave Bryant', # David Bryant
                'andy' => 'Andy',
                'dionoea' => 'Antoine Cellerier', # Antoine Cellerier
                'markun' => 'Marcoen Hirschberg', # Marcoen Hirschberg
                'niobos' => 'Niels Laukens', # Niels Laukens
                'rdjackso' => 'Ryan Jackson', # Ryan Jackson
                'kevin' => 'Kevin Ferrare', # Kevin Ferrare
                'len0x' => 'Anton Oleynikov', # Anton Oleynikov
		'adam' => 'Adam Boot',  # Adam Boot
		'bger' => 'Hristo Kovachev',  # Hristo Kovachev
                'tomal' => 'Tomasz Malesinski', # Tomasz Malesinski
                'lostlogic' => 'Brandon Low', # Brandon Low
                'benbasha' => 'Ben Basha', # Ben Basha 'Paprica'
                'dan' => 'Dan Everton', # Dan Everton 'safetydan'
                'peter' => "Peter D\'Hoye", # Peter D'Hoye 'petur'
                'tucoz' => 'Martin Arver',
                'phaedrus961' => 'Frank Dischner', # Frank Dischner
                'nls' => 'Nils Wallménius', # Nils Wallménius
                'medifebbo' => 'Michael DiFebbo', # Michael DiFebbo
                'kkurbjun' => 'Karl Kurbjun', # Karl Kurbjun
                'bluebrother' => 'Dominik Riebeling', # Dominik Riebeling
                'lowlight' => 'Mark Arigo', # Mark Arigo
                'breaker' => 'Uwe Freese', # Uwe Freese
                'mmmm' => 'Martin Scarratt',
                'raenye' => 'Rani Hod',
                'dan_a' => 'Daniel Ankers',
                'tpdiffenbach' => 'TP Diffenbach',
                'lamed' => 'Shachar Liberman',
                'jdgordon' => 'Jonathan Gordon',
                'jethead71' => 'Mike Sevakis',
                'barrywardell' => 'Barry Wardell',
                'pondlife' => 'Steve Bavin',
                'theli' => 'Anton Romanov',
                'pixelma' => 'Marianne Arnold',
                'gwhite' => 'Greg White',
                'gotthardt' => 'Steve Gotthardt',
                'llorean' => 'Paul Louden',
                'midgey34' => 'Tom Ross',
                'agashlin', => 'Adam Gashlin',
                'nicolasp' => 'Nicolas Pennequin',
                'domonoky' => 'Dominik Wenger',
                'roolku' => 'Robert Kukla',
                'toni' => 'Antonius Hellmann',
                'moos' => 'Mustapha Senhaji',
                'saratoga' => 'Michael Giacomelli',
                'robert' => 'Robert Keevil',
                'lenzone10' => 'Alessio Lenzi',
                'aliask' => 'Will Robertson',
                'james83' => 'James Espinoza',
                'scorche' => 'Austin Appel',
                );

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

    my $path = sprintf("<a class=\"fname\" href=\"$urlroot%s?view=log&pathrev=%d\">%s</a>$diff\n",
                       $file, $rev, $sfile);

    if($a eq "R") {
        $diff = " [<span class=\"fname\">rename</span>]";
    }
    elsif($a eq "M") {
        $diff = sprintf(" [<a class=\"fname\" href=\"$urlroot%s?r1=%d&r2=%d\">diff</a>]",
                        $file, $rev-1, $rev);
    }
    elsif($a eq "A") {
        $diff = " [<span class=\"fname\">new</span>]";
    }
    elsif($a eq "D") {
         $path = sprintf("<a class=\"fname\" href=\"$urlroot%s?view=log&pathrev=%d\">%s</a>$diff\n",
                       $file, $rev-1, $sfile);
        #$path = "<span class=\"fname\">$sfile</span>";
        $diff = " [<span class=\"fname\">gone</span>]";
    }

    return "$path $diff\n";
}

print "<table class=\"changetable\"><tr><th>when</th><th>who</th><th>where</th><th>what</th></tr>\n";

while(<STDIN>) {
    my $l = $_;
    chomp $l;
    if(/^------------------------------------------------------------------------/) {
        if($b[0] || $f[0]) {
            print "<td nowrap>";
            for(@f) {
                printf("%s<br>", file2url($_, $rev));
            }
            print "</td><td>";
            my $br;
            for my $l (@b) {
                $l =~ s:&:&amp;:g;
                $l =~ s:<:&lt;:g;
                $l =~ s:>:&gt;:g;
                $l =~ s!FS *\#(\d+)!<a href=\"http://www.rockbox.org/tracker/task/$1\">FS \#$1</a>!g;
                print "<br>" if($br);
                print $l;
                $br++;
            }
            print "</td></tr>\n";
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
            my $lname = $shortnames{lc($2)} || $2;
            my $t = $4;
            my $d = $3;

            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                gmtime();

            if($d =~ /(\d\d\d\d)-(\d\d)-(\d\d)/) {
                $d = sprintf("%d %s", $3, substr($mname[$2-1], 0, 3));
                if($year != ($1 - 1900)) {
                    $d .= " $1";
                }
            }

            $t =~ s/^(\d\d):(\d\d):(\d\d)/$1:$2/;
            print "<tr><td nowrap>$d $t</td><td>$lname</td>\n";
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
