#!/usr/bin/perl

use DBI;

my $building = $ARGV[0];

my @b;
my %rounds;
my %round;
my %dir; # hash per type for build dir

# number of builds in the output table
my $numout = 20;

sub nicehead {
    my ($file, $title, $onload)=@_;

    open(NICE, ">$file");
    open(READ, "<head.html");
    my $js = <<MOO
  <script type="text/javascript" src="countdown.js"></script>
MOO
;

    while(<READ>) {
        s/_PAGE_/$title/;
        print NICE $_;
    }

    close(NICE);
    close(READ);

}

sub nicefoot {
    my ($file, $date)=@_;

    open(NICE, ">>$file");
    open(READ, "<foot.html");

    print NICE <<MOO
<p>
 Back to <a href="http://www.rockbox.org/daily.shtml">daily builds</a> / <a
 href="http://build.rockbox.org/">SVN builds</a>
<p>
 <a href="http://www.rockbox.org/twiki/bin/view/Main/BuildServer">How To Add a Build Server</a> to the build farm.

MOO
;
    while(<READ>) {
        s/_PAGE_/$date/;
        print NICE $_;
    }
    close(NICE);
    close(READ);
}

sub urlencode {
    shift() if ref($_[0]) || $_[0] eq $DefaultClass;
    my $toencode = shift;

    return undef unless defined($toencode);
    $toencode=~s/([^a-zA-Z0-9_.-])/uc sprintf("%%%02x",ord($1))/eg;
    return $toencode;
}

my $build=0;

sub log2html {
    my ($file)=@_;

    my ($line, $lserver, $date, $rev, $type, $status, $dir);

    $build++; # number of this "round"

    if ($file =~ /(\d+)-/) {
        $rev = $1;
        $rounds{$rev} = 1;
    }
    else {
        warn "No rev in $file";
    }

    open(LOG, "<$file");
    while(<LOG>) {
        $line = $_;
        
        if($line =~ /^Build Server: (.*)/) {
            $lserver = $1;
        }
        elsif($line =~ /^Build Date: (.*)/) {
            $date = $1;
        }
        elsif($line =~ /^Build Dir: (.*)/) {
            # usually after the build type
            $dir{$type}=$1;
        }
        elsif($line =~ /^Build Type: (.*)/) {
            $type = $1;
            
            push @b, $type.$rev;
            
            $alltypes{$type}.="$rev%";
        }
        elsif($line =~ /^Build Status: (.*)/) {
            $status = $1;
        }
        elsif($line =~ /^Build Time: (\d+)/) {
            $build{$rev}{$type}{time} = $1;
            $build{$rev}{$type}{status} = $status;
            $build{$rev}{$type}{date} = $date;
            $build{$rev}{$type}{server} = $lserver;
        }
        else {
            $build{$rev}{$type}{compile} .= $line;
            
            if($line =~ /^([^:]*):(\d*):.*warning: (.*)/) {
                if($3 !~ /\(near/) {
                    # we don't count "(near" comments as warnings
                    $build{$rev}{$type}{warnings}++;
                }
            }
            elsif(($line =~ /^([^:]+):(\d+):(.+)/) ||
                  ($line =~ /: undefined reference to/) ||
                  ($line =~ /gcc: .*: No such file or/) ||
                  ($line =~ /ld returned (\d+) exit status/) ||
                  ($line =~ /^svn: /) ||
                  ($line =~ /^ *make\[.*\*\*\*/) ) {
                # error
                $build{$rev}{$type}{errors}++;
#                    print STDERR "Error $type $date $1 $2\n";
            }
            elsif($line =~ /Using (.*gcc) ([0-9.]+) \(/ ) {
                $build{$rev}{$type}{gcc}="$1 $2";
#                    print STDERR "GCC $1 $2\n";
            }
            elsif($line =~ /Using *(.*ld) ([0-9.]+)/ ) {
                $build{$rev}{$type}{ld}="$1 $2";
#                    print STDERR "LD $1 $2\n";
            }
            
            #print STDERR "M: $line";
        }
    }
}


my $some_dir="data";
opendir(DIR, $some_dir) || die "can't opendir $some_dir: $!";
@logs = sort grep { /\.log$/ } readdir(DIR);
closedir DIR;

for(@logs) {
    log2html("$some_dir/$_");
}

#printf( "<p> %d different builds\n", scalar(keys %alltypes));
print "<table class=\"buildstatus\" cellspacing=\"1\" cellpadding=\"0\"><tr><th>Revision</th>\n";
foreach $t (sort keys %alltypes) {
    my $alt = $t;
    $alt =~ s/FM Recorder/FM/;
    $alt =~ s/Playerold/P-old/;
    $alt =~ s/Player/Play/;
    $alt =~ s/Recorder/Rec/;

    $alt =~ s/Debug/Dbg/;
    $alt =~ s/Normal//;
    $alt =~ s/Simulator/Sim/;
    $alt =~ s/-//g;
    $alt =~ s/ +/ /g;

    print"<th><img width='16' height='130' alt=\"$alt\" src=\"http://build.rockbox.org/dist/build-$t.png\"></th>\n";
}
print "<th>score</th>";
print "</tr>\n";

open(IN, "<output/build-time");
my $prevtime = <IN>;
close(IN);

open(IN, "<output/last-build-time");
my $lasttime = <IN>;
close(IN);

my $numbuilds = scalar(keys %alltypes);
my $js;
if($building) {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) =
        gmtime(time);

    my $text ="Build in progress";
    if($prevtime) {
        my ($dsec,$dmin,$dhour,$dmday,$dmon,$dyear,$dwday,$dyday) =
            gmtime(time()+$prevtime);
        $text = sprintf("Build <span id=\"countdown_text\">expected to complete around %02d:%02d:%02d (in %dmins %dsecs)</span></a>",
                        $dhour, $dmin, $dsec,
                        $prevtime/60, $prevtime%60);
        $js = sprintf("<script type=\"text/javascript\">countdown_refresh(%d,%d,%d,%d,%d,%d);</script>",
                          $dyear+1900, $dmon, $dmday,
                          $dhour, $dmin, $dsec);
    }

    $building =~ s/ /%20/g;

    printf("<tr><td><a class=\"bstamp\" href=\"%s\">%04d-%02d-%02d %02d:%02d</a></td><td class=\"building\" colspan=\"%d\">$text</td></tr>\n",
           $building,
           $year+1900, $mon+1, $mday, $hour, $min,
           $numbuilds, gmtime());
}

my $count=0;
for my $rev (sort {$b <=> $a} keys %rounds) {
    my @types = keys %{$build{$rev}};

    if($count++ >= $numout) {
        last;
    }

    print "<tr align=center>\n";

    my $chlink = "<a class=\"bstamp\" href=\"http://svn.rockbox.org/viewvc.cgi?view=rev;revision=$rev\">$rev</a>";

    my $score=0;
    print "<td nowrap>$chlink</td>\n";

    my %servs;
    my %bt;

    for my $type (sort keys %alltypes) {

        if (not defined $build{$rev}{$type}) {
            print "<td>&nbsp;</td>\n";
            next;
        }

        my $s = $_.$rev{$types[0]};
        my $host = $server{$s};
        if($host) {
            $servs{$host}++;
            $bt{$host}.= " ".$btime{$s};
        }

#        print STDERR "host: $host\n";

        my $ok = 0;
        my $text;
        my $class;

        my $b = \%{$build{$rev}{$type}};

        if ($$b{errors} == 0) {
            if ($$b{status} =~ /Failed/) {
                $text="ld";
                $class="buildfail";
                $score += 20;
            }
            else {
                $ok = 1;
                $text=" 0";
                
                $class="buildok";
                if($$b{warnings}) {
                    $class="buildwarn";
                    $text = $$b{warnings};
                    $score += $$b{warnings};
                }
            }
        }
        else {
            $text=$$b{errors};
            $score += ($$b{errors} * 10) + $$b{warnings};
            if($$b{warnings}) {
                $text .= "<br>(".$$b{warnings}.")";
            }
            $class="buildfail";
        }

        if(!length($text)) {
            $text = "FAIL";
        }
        
        printf("<td class=\"%s\"><a class=\"blink\" href=\"shownewlog.cgi?rev=%s&type=%s\" title=\"%s/%s on %s in %d secs\">%s</a></td>\n",
               $class,
               urlencode($rev), urlencode($type),
               $$b{gcc}, $$b{ld}, $$b{server}, $$b{time},
               $text);
    }
    printf "<td>%d</td>", $score;
    printf("<td><a href=\"cvsmod/serv-$rev.html\">%d</a></td>",
           scalar(keys %servs));
    print "</tr>\n";

    nicehead("output/serv-$rev.html", "Server Stats $stamp");
    open(SER, ">>output/serv-$rev.html");
    my $bu;
    my $se;
    my @out;
    my $totaltime;

    for(sort {$servs{$b} <=> $servs{$a}} keys %servs) {
        my $s = $_;
        $s =~ s/^[^@]+@//;
        my $tot;
        my $avg;
        my @t= split(" ", $bt{$_});
        if($t[0]) {
            for(@t) {
                $tot += $_;
            }
            $avg = $tot/scalar(@t);
        }

        push @out, sprintf("<tr><td>%s</td><td>%s</td><td>%d</td><td>%d</td><td>(%s)</td></tr>\n",
                           $s, $servs{$_}, $tot, $avg, $bt{$_});
        $se++;
        $bu += $servs{$_};
        $totaltime += $tot;
    }
    printf SER ("For these %d builds the following %d servers were used. (<a href=\"chlog-$urlstamp.html\">changelog</a>, <a href=\"dbg-$urlstamp.log\">buildmaster log</a>)<p><table>\n<tr><th>Server</th><th>Builds</th><th>Total Time</th><th>Average</th><th>All Times</th></tr>\n",
                $bu, $se);
    print SER @out;
    print SER "</table>\n";
    close(SER);

    nicefoot("output/serv-$rev.html", $stamp);
}

printf "</table>\n";
#print "%d builds in %d seconds (%dmins %dsecs) makes %.1f seconds/build (the most recent build took %dmins %dsecs)\n",
    $numbuilds, $prevtime, $prevtime/60, $prevtime%60, $prevtime/$numbuilds,
    $lasttime/60, $lasttime%60;

print $js;
