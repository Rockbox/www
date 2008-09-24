
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
          "source"
          );

sub buildtable {
    print "<p><table class='rockbox' cellpadding=\"0\"><tr valign=top>\n";
    for my $m (@list) {
        {
            my $pack="http://download.rockbox.org/release/3.0/rockbox-$m-3.0.zip";
            my $name= $longname{$m},
            my $version;
            my $rev="3.0";
            if($m eq "source") {
                $pack="http://download.rockbox.org/release/3.0/rockbox-3.0.7z";
                
                $m="source";
                my $size = (stat($pack))[7];
                $name= sprintf("Source code<br>%.1fMB", $size/(1024*1024));
            }

            if($col++ > 6) {
                print "</tr><tr valign=\"top\">";
                $col=1;
            }
            printf("<td align='center'><a href=\"%s\" title=\"%s\"><img border=\"0\" src=\"http://www.rockbox.org%s\" alt=\"%s\"><p>%s</a></td>\n",
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
