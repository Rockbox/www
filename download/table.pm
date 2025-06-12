require "/home/rockbox/www/rockbox.pm";

sub buildtable {
    print "<p><table class='rockbox' cellpadding=\"0\"><tr valign=top>\n";
    for my $m (sort byname keys %builds) {
        {
            next if ($builds{$m}{status} < 3 && !defined($builds{$m}{release}));
            $builds{$m}{release} = $publicrelease unless defined($builds{$m}{release});
            next if ($builds{$m}{release} > $publicrelease);

            # the release hash and the *release variables are from builds.pm

            my $basedir="//download.rockbox.org/release/$builds{$m}{release}";
            my $pack="$basedir/rockbox-$m-$builds{$m}{release}.zip";
            my $name= $builds{$m}{name};
            my $mans;
            my $obsolete = "";
            if($m eq "source") {
                $pack="$basedir/rockbox-source-$builds{$m}{release}.7z";
            }
            elsif($m eq "fonts") {
                $pack="$basedir/rockbox-fonts-$builds{$m}{release}.zip";
            }
            else {
                my $docs = manualname($m);
                my $voice = voicename($m);
		if ($builds{$m}{status} == 0 || $builds{$m}{release} != $publicrelease) {
                   $obsolete = "<br><br><i>Retired - v$builds{$m}{release}</i>";
		}
	        my $extra = "<br><a href=\"$basedir/rockbox-fonts-$builds{$m}{release}.zip\">Fonts</a>";
	        $extra .= "<br><a href=\"$basedir/rockbox-source-$builds{$m}{release}.7z\">Source</a>";
		$mans = "";
		if (-f "../../download/release/$builds{$m}{release}/rockbox-$docs-$builds{$m}{release}.pdf") {
                  $mans .= "<br><a href=\"$basedir/rockbox-$docs-$builds{$m}{release}.pdf\">PDF Manual</a>";
                }
		if (-f "../../download/release/$builds{$m}{release}/rockbox-$docs-$builds{$m}{release}-html.zip") {
                  $mans .= "<br><a href=\"$basedir/rockbox-$docs-$builds{$m}{release}-html.zip\">HTML Manual</a>";
                }

		foreach my $v (&allvoices) {
		  if (-f "../../download/release/$builds{$m}{release}/voice-$voice-$builds{$m}{release}-$v.zip") {
		    $mans .= "<br><a href=\"$basedir/voice-$voice-$builds{$m}{release}-$v.zip\">Voice ($voices{$v}{short})</a>";
                  }
		}
		$mans .= "$extra";
            }

            if($col++ > 6) {
                print "</tr><tr valign=\"top\">";
                $col=1;
            }
            printf("<td><table><tr><td height='85px' align='center'><img border=\"0\" src=\"//www.rockbox.org%s\" alt=\"$name\"></td></tr><tr><td align='center'><small>$name<br><a href=\"$pack\" title=\"$name\"><p>Firmware</a>$mans</small>$obsolete</td></tr></table></td>\n",
                   playerpic($m));
        }
    }
    print "</tr></table>";
}

1;
