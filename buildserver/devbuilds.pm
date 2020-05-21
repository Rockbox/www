my $basedir = "/home/rockbox/build";

sub buildtable {
    print "<p><table class='rockbox' cellpadding=\"0\"><tr valign=top>\n";
    for my $m (usablebuilds()) {
        if( ($m =~ /source/ ) || -r "$basedir/data/rockbox-$m.zip") {
            my $pack="data/rockbox-$m.zip";
            my $name= $builds{$m}{name},
            my $version = "";
            my $rev="broken?";
	    my @ver = `unzip -p data/rockbox-$m.zip .rockbox/rockbox-info.txt`;
	    $version = (grep /^Version/, @ver)[0];
	    chomp $version;
	    if($version =~ /^Version: *(\w+)/) {
		$rev = $1;
	    }
	    else {
		print "<br>Failed regex: $version\n";
	    }
            if($col++ > 7) {
                print "</tr><tr valign=\"top\">";
                $col=1;
            }
            printf("<td align='center'><a href=\"$pack\" title=\"$name\"><img border=\"0\" src=\"//www.rockbox.org%s\" alt=\"$name\"><p>$name</a><br><small>$rev</small></td>\n",
                   playerpic($m));
        }
        else {
            #print "<br>MISSING: $basedir/data/rockbox-$m.zip\n";
        }
    }
    print "</tr></table>";
}

1;
