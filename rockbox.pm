# short name to image mapping
%model=("player" => "/playerpics/player-small.png",
        "recorder" => "/playerpics/recorder-small.png",
        "fmrecorder" => "/playerpics/recorderv2fm-small.png",
        "recorderv2" => "/playerpics/recorderv2fm-small.png", 
        "recorder8mb" => "/playerpics/recorder-small.png",
        "fmrecorder8mb" => "/playerpics/recorderv2fm-small.png",
        'ondiosp' => "/playerpics/ondiosp-small.png",
        'ondiofm' => "/playerpics/ondiofm-small.png",
        'h100' => "/playerpics/h100-small.png",
        'h120' => "/playerpics/h100-small.png",
        'h300' => "/playerpics/h300-small.png",
        'ipodcolor' => "/playerpics/ipodcolor-small.png",
        'ipodnano' => "/playerpics/ipodnano-small.png",
        'ipod4gray' => "/playerpics/ipod4g-small.png",
        'ipodvideo' => "/playerpics/ipodvideo-small.png",
        'ipodvideo64mb' => "/playerpics/ipodvideo-small.png",
        'ipod3g' => "/playerpics/ipod3g-small.png",
        'ipodmini2g' => "/playerpics/ipodmini-small.png",
        'ipodmini1g' => "/playerpics/ipodmini-small.png",
        'iaudiox5' => "/playerpics/x5-small.png",
        'iaudiom5' => "/playerpics/m5-small.png",
        'h10' => '/playerpics/h10-small.png',
        'h10_5gb' => '/playerpics/h10_5gb-small.png',
        "sansae200" => "/playerpics/e200-small.png",
        "sansac200" => "/playerpics/c200-small.png",
        "gigabeatf" => "/playerpics/gigabeatf-small.png",
        'ipod1g2g' => "/playerpics/ipod1g2g-small.png",
        'mrobe100' => '/rockbox100.png',
        'mrobe500' => '/rockbox100.png',

        "install" => "/playerpics/install.png",
        "fonts" => "/rockbox100.png",
        "source" => "/rockbox100.png");

# short name to long name mapping
%longname=("player" => "Archos Player/Studio",
           "recorder" => "Archos Recorder v1",
           "fmrecorder" => "Archos FM Recorder",
           "recorderv2" => "Archos Recorder v2", 
           "recorder8mb" => "Archos Recorder 8MB",
           "fmrecorder8mb" => "Archos FM Recorder 8MB",
           'ondiosp' => "Archos Ondio SP",
           'ondiofm' => "Archos Ondio FM",
           'h100' => "iriver H100/115",
           'h120' => "iriver H120/140",
           'h300' => 'iriver H320/340',
           'h10' => 'iriver H10 20GB',
           'h10_5gb' => 'iriver H10 5GB',
           'ipodcolor' => 'iPod color/Photo',
           'ipodnano' => 'iPod Nano 1st gen',
           'ipod4gray' => 'iPod 4th gen Grayscale',
           'ipodvideo' => 'iPod Video 30GB',
           'ipodvideo64mb' => 'iPod Video 60/80GB',
           'ipod3g' => 'iPod 3rd gen',
           'ipod1g2g' => 'iPod 1st and 2nd gen',
           'ipodmini2g' => 'iPod Mini 2nd gen',
           'ipodmini1g' => 'iPod Mini 1st gen',
           'iaudiox5' => 'iAudio X5',
           'iaudiom5' => 'iAudio M5',
           "sansae200" => "SanDisk Sansa e200",
           "sansac200" => "SanDisk Sansa c200",
           "gigabeatf" => "Toshiba Gigabeat F",
           'mrobe100' => 'Olympus M-Robe 100',
           'mrobe500' => 'Olympus M-Robe 500',
           "install" => "Windows Installer",
           "fonts" => "Fonts",
           "source" => "Source Archive");

sub header {
    my ($t) = @_;
    print "Content-Type: text/html\n\n";
    open (HEAD, "/home/bjst/rockbox_html/head.html");
    while(<HEAD>) {
        $_ =~ s:^<title>Rockbox<\/title>:<title>$t<\/title>:;
        $_ =~ s:^<h1>_PAGE_<\/h1>:<h1>$t<\/h1>:;
        print $_;
    }
    close(HEAD);
}

sub footer {
    open (FOOT, "/home/bjst/rockbox_html/foot.html");
    while(<FOOT>) {
        print $_;
    }
    close(FOOT);
}

1;