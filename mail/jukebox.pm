
sub title {
    my ($title)=@_;

    print "<div class=title>$title</div>\n";
}

sub header {
    my ($title, $ourid)=@_;
    print "Content-Type: text/html\n\n";
    catfile("../indextop.html");
}

sub footer {
    catfile("../indexbot.html");
}

sub catfile {
    my ($file)=@_;
    open(SHOW, "<$file");
    while(<SHOW>) {
        print $_;
    }
    close(SHOW);
}

sub timediff {
    my ($now, $time)=@_;
    my $rel;
    my $diff;
    if ($time <3600000) {
	return "minns inte";
    }
    $diff=$now-$time;
    if($diff < 3600) {
        $rel = sprintf("%d minuter och %d sekunder",
                       $diff/60,
                       $diff%60);
    }
    elsif($diff < (24*3600) ) {
        $diff /= 60; # count minutes

        $rel = sprintf("%d timmar och %d minuter",

                       (0+$diff/(0+60)),

                       $diff%60);
    }
    else {
        $diff /= 3600; # count hours
        $rel = sprintf("%d timmar", $diff);
    }
    return $rel;
}

1;
