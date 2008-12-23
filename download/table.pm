my $defaultversion="3.1";

#my %diffver = ( 'player'        => '3.0.1',
#                'recorder'      => '3.0.1',
#                'recorder8mb'   => '3.0.1',
#                'fmrecorder'    => '3.0.1',
#                'fmrecorder8mb' => '3.0.1',
#                'recorderv2'    => '3.0.1',
#                'ondiofm'       => '3.0.1',
#                'ondiosp'       => '3.0.1');

my @list=(
          "player",
          "recorder", "recorder8mb",
          "fmrecorder", "fmrecorder8mb",
          "recorderv2",
          "ondiofm", "ondiosp",
          "iaudiom5", "iaudiox5", #"iaudiom3",
          "h100", "h120", "h300",
          "h10_5gb", "h10",

          "ipod1g2g", "ipod3g",
          "ipod4gray", "ipodcolor",
          "ipodvideo", "ipodvideo64mb",
          "ipodmini1g", "ipodmini2g",
          "ipodnano",

          "gigabeatf",
          "sansae200", "sansac200",
          "mrobe100",
          "source", "fonts"
          );

sub buildtable {
    print "<p><table class='rockbox' cellpadding=\"0\"><tr valign=top>\n";
    for my $m (@list) {
        {
            my $version = $diffver{$m} || $defaultversion;
            my $basedir="http://download.rockbox.org/release/$version";
            my $pack="$basedir/rockbox-$m-$version.zip";
            my $name= $longname{$m},
            my $mans;
            if($m eq "source") {
                $pack="$basedir/rockbox-$version.7z";
            }
            elsif($m eq "fonts") {
                $pack="$basedir/rockbox-fonts-$version.zip";
            }
            else {
                my $docs = $model2docs{$m} || $m;
                my $voice = $m;

                # cut off the memory sizes
                $voice =~ s/8mb//g;
                $voice =~ s/64mb//g;

                $mans=sprintf("<br><a href=\"$basedir/rockbox-%s-$version.pdf\">PDF manual</a><br><a href=\"$basedir/%s-$version-english.zip\">English voice</a>",
                              $docs, $voice);
            }

            if($col++ > 6) {
                print "</tr><tr valign=\"top\">";
                $col=1;
            }
            printf("<td align='center'><a href=\"%s\" title=\"%s\"><img border=\"0\" src=\"http://www.rockbox.org%s\" alt=\"%s\"><p>%s</a>$mans</td>\n",
                   $pack,
                   $longname{$m},
                   $model{$m},
                   $longname{$m},
                   $name,
                   );
        }
    }
    print "</tr></table>";
}

1;
