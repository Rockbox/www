
# short name to image mapping
%model=("player" => "/docs/newplayer_t.jpg",
        "recorder" => "/docs/recorder_t.jpg",
        "fmrecorder" => "/docs/fmrecorder_t.jpg",
        "recorderv2" => "/docs/fmrecorder_t.jpg", 
        "recorder8mb" => "/docs/recorder_t.jpg",
        "fmrecorder8mb" => "/docs/fmrecorder_t.jpg",
        'ondiosp' => "/docs/ondiosp_t.jpg",
        'ondiofm' => "/docs/ondiofm_t.jpg",
        'h100' => "/docs/h100_t.jpg",
        'h120' => "/docs/h100_t.jpg",
        'h300' => "/docs/h300-60x80.jpg",
        'ipodcolor' => "/docs/color_t.jpg",
        'ipodnano' => "/docs/nano_t.jpg",
        'ipod4gray' => "/docs/ipod4g2pp_t.jpg",
        'ipodvideo' => "/docs/ipodvideo_t.jpg",
        'ipodvideo64mb' => "/docs/ipodvideo_t.jpg",
        'ipod3g' => "/docs/ipod3g_t.jpg",
        'ipodmini2g' => "/docs/ipodmini_t.jpg",
        'ipodmini1g' => "/docs/ipodmini_t.jpg",
        'iaudiox5' => "/docs/iaudiox5_t.jpg",
        'iaudiom5' => "/docs/iaudiom5_t.jpg",
        'h10' => '/docs/h10_20gb.jpg',
        'h10_5gb' => '/docs/h10_5gb.jpg',
        "install" => "/docs/install.png",
        "sansae200" => "/docs/sansae200_t.jpg",
        "gigabeatf" => "/docs/t_gigabeatf.png",

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
           'ipodvideo' => 'iPod Video',
           'ipodvideo64mb' => 'iPod Video 64MB',
           'ipod3g' => 'iPod 3rd gen',
           'ipodmini2g' => 'iPod Mini 2nd gen',
           'ipodmini1g' => 'iPod Mini 1st gen',
           'iaudiox5' => 'iAudio X5',
           'iaudiom5' => 'iAudio M5',
           "sansae200" => "SanDisk Sansa e200",
           "gigabeatf" => "Toshiba Gigabeat F",
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
