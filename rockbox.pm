require "/home/rockbox/rockbox_git_clone/tools/builds.pm";

my $sitedir = "/home/rockbox/www";

sub playerpic {
    my $m = shift @_;

    my $p = $builds{$m}{icon} ?
        "/playerpics/$builds{$m}{icon}-small.png" :
        "/playerpics/$m-small.png";

    if (-r "$sitedir/$p") {
        return $p;
    }
    else {
        return "/rockbox100.png";
    }
}

sub header {
    my ($t) = @_;
    print "Content-Type: text/html\n\n";
    open (HEAD, "$sitedir/head.html");
    while(<HEAD>) {
        $_ =~ s:^<title>Rockbox<\/title>:<title>$t<\/title>:;
        $_ =~ s:^<h1>_PAGE_<\/h1>:<h1>$t<\/h1>:;
        print $_;
    }
    close(HEAD);
}

sub header_b {
    my ($t) = @_;
    open (HEAD, "$sitedir/head.html");
    while(<HEAD>) {
        $_ =~ s:^<title>Rockbox<\/title>:<title>$t<\/title>:;
        $_ =~ s:^<h1>_PAGE_<\/h1>:<h1>$t<\/h1>:;
        print $_;
    }
    close(HEAD);
}

sub footer {
    open (FOOT, "$sitedir/foot.html");
    while(<FOOT>) {
        print $_;
    }
    close(FOOT);
}

1;
