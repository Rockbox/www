#!/usr/bin/perl

my $some_dir="output";

opendir(DIR, $some_dir) || die "can't opendir $some_dir: $!";
@logs = sort grep { /^allbuilds/ && -f "$some_dir/$_" } readdir(DIR);
closedir DIR;

my $building = $ARGV[0];

my @b;
my @rounds;
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
 Back to <a href="//www.rockbox.org/daily.shtml">daily builds</a> / <a
 href="//build.rockbox.org/">SVN builds</a>
<p>
 <a href="//www.rockbox.org/twiki/bin/view/Main/BuildServer">How To Add a Build Server</a> to the build farm.

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

    my $log=0;
    my $bigstart=-1;

    open(LOG, "<$file");
    while(<LOG>) {
        $line = $_;

        if($line =~ /^Build Server: (.*)/) {
            $lserver = $1;
        }
        elsif($line =~ /^Build Time: (\d+)/) {
            $btime = $1;
        }
        elsif( $line =~ /^Build End All Systems/) {
            # this is how a complete build round MUST stop
            $bigstart=0;
        }
        if(!$log) {
            if( $line =~ /^Build Start All Systems/) {
                if($bigstart > 0) {
                    # the round was not completed properly until this new one
                    # starts so we don't care of the previous one but instead
                    # try to hide it
                }
                else {
                    $bigstart=1;
                    $build++; # number of this "round"
                    push @rounds, $build;
                }
            }
            elsif($line =~ /^Build Start Single/) {
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

                push @b, $type.$date;

                $alltypes{$type}.="$date%";

                # remember all types in this round
                $round{$build}.= "$type$date%";
            }
            elsif($line =~ /^Build Status: (.*)/) {
                $status{$type.$date} = $1;
                $type{$type.$date} = $type;
                $date{$type.$date} = $date;
                $server{$type.$date} = $lserver;
            }
            elsif($line =~ /^Build Log Start/) {
                $btime{$type.$date} = $btime;
                $log = 1;
            }
        }
        else {
            if($line =~ /^Build Log End/) {
                $log = 0;
            }
            else {
                $compile{$type.$date} .= $line;

                if($line =~ /^([^:]*):(\d*):.*warning: (.*)/) {
                    if($3 !~ /\(near/) {
                        # we don't count "(near" comments as warnings
                        $warnings{$type.$date}++;
                    }
                }
                elsif(($line =~ /^([^:]+):(\d+):(.+)/) ||
                      ($line =~ /: undefined reference to/) ||
                      ($line =~ /gcc: .*: No such file or/) ||
                      ($line =~ /ld returned (\d+) exit status/) ||
                      ($line =~ /^ *make\[.*\*\*\*/) ) {
                    # error
                    $errors{$type.$date}++;
#                    print STDERR "Error $type $date $1 $2\n";
                }
                elsif($line =~ /Using (.*gcc) ([0-9.]+) \(/ ) {
                    $gcc{$type.$date}="$1 $2";
#                    print STDERR "GCC $1 $2\n";
                }
                elsif($line =~ /Using *(.*ld) ([0-9.]+)/ ) {
                    $ld{$type.$date}="$1 $2";
#                    print STDERR "LD $1 $2\n";
                }
                
                #print STDERR "M: $line";
            }
        }
    }
}


for(@logs) {
    log2html("$some_dir/$_");
}

#printf( "<p> %d different builds\n", scalar(keys %alltypes));
print "<table class=\"buildstatus\" cellspacing=\"1\" cellpadding=\"0\"><tr><th>Timestamp</th>\n";
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

    printf ("<th><img width='16' height='130' alt=\"$alt\" src=\"/dist/%s.png\"></th>\n", $dir{$t});
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
for(reverse @rounds) {
    my @types = split("%", $round{$_} );

    if($count++ >= $numout) {
        last;
    }

    print "<tr align=center>\n";

    my $batch = $date{$types[0]};
    my $stamp=$batch;

    if( -f "output/chlog-$batch.html") {
        my $vis = $batch;
        $vis =~ s/ /%20/g;
	# reformat datestamp
        $batch =~ s/(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)Z/$1-$2-$3 $4:$5/g;
        $batch = "<a class=\"bstamp\" href=\"cvsmod/chlog-$vis.html\">$batch</a>";
    }

    my $score=0;
    printf("<td nowrap>%s</td>\n", $batch);

    my %servs;
    my %bt;

    for(sort keys %alltypes) {
        my $show = $_;
        my $found;

        my $s = $_.$date{$types[0]};
        my $host = $server{$s};
        if($host) {
            $servs{$host}++;
            $bt{$host}.= " ".$btime{$s};
        }

#        print STDERR "host: $host\n";

        for(@types) {
            if($show eq $type{$_}) {
                my $stat =  $status{$_};
                my $ok = 0;
                my $text;
                my $class;

                if ($errors{$_} == 0) {
                    if ($stat =~ /Failed/) {
                        $text="ld";
                        $class="buildfail";
                        $score += 20;
                    }
                    else {
                        $ok = 1;
                        $text=" 0";
                        
                        $class="buildok";
                        if($warnings{$_}) {
                            $class="buildwarn";
                            $text = $warnings{$_};
                            $score += $warnings{$_};
                        }
                    }
                }
                else {
                    $text=$errors{$_};
                    $score += ($errors{$_} * 10) + $warnings{$_};
                    if($warnings{$_}) {
                        $text .= "<br>(".$warnings{$_}.")";
                    }
                    $class="buildfail";
                }

                if(!length($text)) {
                    $text = "FAIL";
                }

                my $ser = $server{$_};
                $ser =~ s/rbclient\@//;

                printf("<td class=\"%s\"><a class=\"blink\" href=\"showlog.cgi?date=%s&type=%s\" title=\"%s/%s on %s in %d secs\">%s</a></td>\n",
                       $class,
                       urlencode($date{$_}), urlencode($type{$_}),
                       $gcc{$_}, $ld{$_}, $ser, $btime{$_},
                       $text);
                $found=1;
                last;
            }
        }
        if(!$found) {
            print "<td>&nbsp;</td>\n";
        }

    }
    printf "<td>%d</td>", $score;
    my $urlstamp = $stamp;
    $urlstamp =~ s/ /%20/g;
    printf("<td><a href=\"cvsmod/serv-$urlstamp.html\">%d</a></td>",
           scalar(keys %servs));
    print "</tr>\n";

    nicehead("output/serv-$stamp.html", "Server Stats $stamp");
    open(SER, ">>output/serv-$stamp.html");
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

    nicefoot("output/serv-$stamp.html", $stamp);
}

printf "</table> %d builds in %d seconds (%dmins %dsecs) makes %.1f seconds/build (the most recent build took %dmins %dsecs)\n",
    $numbuilds, $prevtime, $prevtime/60, $prevtime%60, $prevtime/$numbuilds,
    $lasttime/60, $lasttime%60;

print $js;
