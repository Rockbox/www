#!/usr/bin/perl

require "nicedate.pm";
require "CGI.pm";

my $tree="/sites/maildump";

my %listnames = ('rockbox' => 'Users',
                 'rockbox-dev' => 'Devel');

my %listrealname = ('rockbox' => 'rockbox',
                    'rockbox-dev' => 'rockbox-dev');

opendir(DIR, $tree) || die "can't opendir $tree: $!";
my @archives = grep { /^(.*)-(\d\d\d\d)-(\d\d)$/ && -d "$tree/$_" } readdir(DIR);
closedir DIR;

my $numberoutput=10;
if ($ARGV[0]) {
    $numberoutput = $ARGV[0];
}
my $compact = 0;
if ($ARGV[1]) {
    $compact = 1;
}

my %d;

my %log; # {$file}=$date
my %name; # {$file}=$name
my %email; # {$file}=$email
my %subject; # {$file}=$subject
my %inreplyto; # {$file}=$subject

my %store; # subject counter {$subject)=$num
my %start; # thread start {$subject}=$file
my %last; # thread end {$subject}=$file

for $f (sort @archives) {
    if($f =~ /^(.*)-(\d\d\d\d-\d\d)$/) {
        $d{$2}.="$f ";
    }
    #print "$f\n";
}

my $numscannedmails;

for $date (reverse sort keys %d) {
    if($date =~ /^(\d\d\d\d)-(\d\d)$/) {
        my ($y, $m) = ($1, $2);
        # now we have a year and date to scan

        my @check = split(/ /, $d{$date});
        for my $a (@check) {
            my $m=0;
            for(keys %listnames) {
                my $l = $listrealname{$_};
                # print "L: $a contains $l-archive\n";
                if($a =~ /${l}-archive/) {
                    $m = 1;
                    last;
                }
            }
            next if(!$m); # only scan fine archives
            #print "$tree$a\n";
            getthreads("$tree/$a");
        }

        if($numscannedmails > 1000) {
            last;
        }
    }
}

my $c;
my %shown;

if ($compact) {
print <<MOO
<table class="latestmail" 
 summary="lists recent Rockbox mailing list postings">
<caption>Recent Threads on the Mailing Lists</caption>
<tr class="tabletop">
<th>when</th>
<th>what</th>
<th>who</th>
</tr>
MOO
    ;
}
else {
print <<MOO
<table class="latestmail" 
 summary="lists several recent Rockbox mailing list postings">
<caption>Recent Threads on the Mailing Lists</caption>
<tr class="tabletop">
<th>Subject</th>
<th>GMT</th>
<th>Author</th>
<th>Thread</th>
<th>List</th>
</tr>
MOO
    ;
}

for(reverse sort { $log{$a} cmp $log{$b} } keys %log) {


    my $s = $subject{$_};
 
    my $thr;
    my $numthr = $store{$subject{$_}};

    if($start{$s} eq $_) {
        if($numthr > 1) {
            $thr="$numthr first";
        }
        else {
            $thr="1";
        }
    }
    else {
        my $st = $start{$s};      
        my $s = file2url($start{$s});

        $thr = "$numthr";
        if($st) {
            $thr .= " <a href=\"$s\">first</a>";
        }
    }

    if(!$shown{$s}) {
        my $short = $name{$_};

        my $subj = $subject{$_};
        if(0 and length($subj) > 40) {
            $subj = substr($subj, 0, 40)."...";
        }

        my $subjectline=sprintf("<td><a href=\"%s\">%s</a></td>\n",
                                file2url($_),
                                $subj?&CGI::escapeHTML($subj):"(no subject)");

        #20041105 11:05:25
        my $da = $log{$_};
        my $stamp;
        if($da =~ /^(\d\d\d\d\d\d\d\d)(\d\d)(\d\d)(\d\d)/) {
            $stamp=`date -u -d "$1 $2:$3:4" +%s`; # this is GMT
            chomp $stamp;
            $stamp=reltime($stamp);
        }

        my $list=file2list($_);
        my $listdesc = listname2desc($list);
        my $listurl="//www.rockbox.org/mail/#".$listrealname{$list};

        print "<tr class=\"%s\">";
        my $line;
        if ($compact) {
            printf("<td>%s</td>$subjectline<td>%s</td></tr>\n",
                   $stamp,
                   $short);
        }
        else {
            printf("$subjectline<td>%s</td><td>%s</td><td>%s</td><td><a href=\"%s\">%s</a></td></tr>\n",
                   $stamp,
                   $short,
                   $thr,
                   $listurl,
                   $listdesc);
        }

        if(++$c>=$numberoutput) {
            last;
        }
        $shown{$s}++;
    }
}
print "</table>\n";

sub file2url {
    my ($file)=@_;
    $file =~ s!^$tree!//www.rockbox.org/mail/archive/!;
    return $file;
}

sub file2list {
    my ($file)=@_;
    $file =~ s!^$tree!!;
    $file =~ s/-archive-([0-9\/-]*)\.shtml//;
    return $file;
}

#<!-- isoreceived="20041102134857" -->
#<!-- sent="Tue, 2 Nov 2004 14:48:55 +0100 (CET)" -->
#<!-- isosent="20041102134855" -->
#<!-- name="Daniel Stenberg" -->
#<!-- email="Daniel.Stenberg@contactor.se" -->
#<!-- subject="Re: Nyligen publicerat - ska allt finnas där?" -->

sub parsehtmlfile {
    my ($file) = @_;

    open(FILE, "<$file");
    my ($date, $name, $email, $subject, $inreplyto);
    while(<FILE>) {
        if(/^<!-- isoreceived=\"([^\"]*)\"/) {
            # this is GMT
            $date = $1;
        }
        elsif(/^<!-- name=\"([^\"]*)\"/) {
            $name = $1;
        }
        elsif(/^<!-- email=\"([^\"]*)\"/) {
            $email = $1;
        }
        elsif(/^<!-- subject=\"([^\"]*)\"/) {
            my $hm = $1;
            $hm =~ s/\&ndash;/-/g;
            $subject = &CGI::unescapeHTML($hm);
        }
        elsif(/^<!-- inreplyto=\"([^\"]*)\"/) {
            $inreplyto = $1;
        }
        elsif(/^<!-- body=\"start\" -->/) {
            last;
        }
    }
    close(FILE);
    return $date, $name, $email, $subject, $inreplyto;
}


sub getthreads {
    my ($dir) = @_;

    opendir(DIR, $dir) || die "can't opendir $dir: $!";
    my @mails = grep { /^(\d+)\.shtml$/ && -f "$dir/$_" } readdir(DIR);
    closedir DIR;

    #print "MAILS: ";
    #print @mails;

    for $m (reverse sort @mails) {
        #print " $dir/$m\n";
        my $file = "$dir/$m";
        my ($date, $name, $email, $subject, $inreplyto)= parsehtmlfile($file);

        $numscannedmails++;

        my $s= $subject;

        $s =~ s/^((Sv|Réf[. ]*|Re *|RE\.|Fwd|AW|FW|Re\[(\d+)\]): *)*//ig;
        $s =~ s/[ \t\n]+/ /g;

        $store{$s}++;

        if(!$inreplyto) {
            # thread-starter
            $start{$s}=$file;
        }
        else {
            if(!$last{$s}) {
                $last{$s} = $file;
            }
        }

        $name =~ s/(.*)_at_(.*)/$1/;

        $log{$file}=$date;
        $name{$file}=$name;
        $email{$file}=$email;
        $subject{$file}=$s;
        $inreplyto{$file}=$inreplyto;

    }

}

sub listname2desc {
    my ($short)= @_;

    my $n = $listnames{$short};

    if($n) {
        return $n;
    }

    return $short;
}
