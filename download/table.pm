my $version="3.0";
my $basedir="http://download.rockbox.org/release/$version/";


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
            my $pack="$basedir/rockbox-$m-$version.zip";
            my $name= $longname{$m},
            my $version;
            my $mans;
            if($m eq "source") {
                $pack="$basedir/rockbox-$version.7z";
            }
            elsif($m eq "fonts") {
                $pack="$basedir/rockbox-fonts-$version.zip";
            }
            else {
                $mans=sprintf("<br><a href=\"$basedir/rockbox-%s-$version.pdf\">PDF manual</a>", $model2docs{$m});
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
