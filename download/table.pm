require "/sites/rockbox.org/www/rockbox.pm";

sub buildtable {
    print "<p><table class='rockbox' cellpadding=\"0\"><tr valign=top>\n";
    for my $m (sort byname keys %builds) {
        {
            next if ($builds{$m}{status} < 3);

            # the release hash is in ../rockbox.pm
            my $version = $publicrelease;
            my $basedir="http://download.rockbox.org/release/$version";
            my $pack="$basedir/rockbox-$m-$version.zip";
            my $name= $builds{$m}{name};
            my $mans;
            if($m eq "source") {
                $pack="$basedir/rockbox-$version.7z";
            }
            elsif($m eq "fonts") {
                $pack="$basedir/rockbox-fonts-$version.zip";
            }
            else {
                my $docs = manualname($m);
                my $voice = voicename($m);

                $mans="<br><a href=\"$basedir/rockbox-$docs-$version.pdf\">PDF manual</a><br><a href=\"$basedir/$voice-$version-english.zip\">English voice</a>";
            }

            if($col++ > 6) {
                print "</tr><tr valign=\"top\">";
                $col=1;
            }
            printf("<td align='center'><a href=\"$pack\" title=\"$name\"><img border=\"0\" src=\"http://www.rockbox.org%s\" alt=\"$name\"><p>$name</a>$mans</td>\n",
                   playerpic($m));
        }
    }
    print "</tr></table>";
}

1;
