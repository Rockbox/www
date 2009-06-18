# short name to image mapping
%model=('player' => '/playerpics/player-small.png',
        'recorder' => '/playerpics/recorder-small.png',
        'fmrecorder' => '/playerpics/recorderv2fm-small.png',
        'recorderv2' => '/playerpics/recorderv2fm-small.png', 
        'recorder8mb' => '/playerpics/recorder-small.png',
        'fmrecorder8mb' => '/playerpics/recorderv2fm-small.png',
        'ondiosp' => '/playerpics/ondiosp-small.png',
        'ondiofm' => '/playerpics/ondiofm-small.png',
        'h100' => '/playerpics/h100-small.png',
        'h120' => '/playerpics/h100-small.png',
        'h300' => '/playerpics/h300-small.png',
        'ipodcolor' => '/playerpics/ipodcolor-small.png',
        'ipodnano' => '/playerpics/ipodnano-small.png',
        'ipod4gray' => '/playerpics/ipod4g-small.png',
        'ipodvideo' => '/playerpics/ipodvideo-small.png',
        'ipodvideo64mb' => '/playerpics/ipodvideo-small.png',
        'ipod3g' => '/playerpics/ipod3g-small.png',
        'ipodmini2g' => '/playerpics/ipodmini-small.png',
        'ipodmini1g' => '/playerpics/ipodmini-small.png',
        'iaudiox5' => '/playerpics/x5-small.png',
        'iaudiom5' => '/playerpics/m5-small.png',
        'iaudiom3' => '/playerpics/m3-small.png',
        'h10' => '/playerpics/h10-small.png',
        'h10_5gb' => '/playerpics/h10_5gb-small.png',
        'hdd1630' => '/rockbox100.png', # lacks small picture
        'sansae200' => '/playerpics/e200-small.png',
        'sansac200' => '/playerpics/c200-small.png',
        'gigabeatf' => '/playerpics/gigabeatf-small.png',
        'gigabeats' => '/playerpics/gigabeats-small.png',
        'ipod1g2g' => '/playerpics/ipod1g2g-small.png',
        'mrobe100' => '/playerpics/mrobe100-small.png',
        'mrobe500' => '/rockbox100.png', # lacks small picture
        'creativezvm30' => '/rockbox100.png', # lacks small picture
        'creativezvm60' => '/rockbox100.png', # lacks small picture
        'creativezenvision' => '/rockbox100.png', # lacks small picture
        'sansaclip' => '/rockbox100.png', # lacks small picture
        'sansafuze' => '/rockbox100.png', # lacks small picture
        'sansae200v2' => '/playerpics/e200-small.png',
        'sansam200v4' => '/rockbox100.png', # lacks small picture
        'yh820' => '/rockbox100.png', # lacks small picture
        'yh920' => '/rockbox100.png', # lacks small picture
        'yh925' => '/rockbox100.png', # lacks small picture

        'install' => '/playerpics/install.png',
        'fonts' => '/rockbox100.png',
        'source' => '/rockbox100.png');

# short name to long name mapping
%longname=('player' => 'Archos Player/Studio',
           'recorder' => 'Archos Recorder v1',
           'fmrecorder' => 'Archos FM Recorder',
           'recorderv2' => 'Archos Recorder v2', 
           'recorder8mb' => 'Archos Recorder 8MB',
           'fmrecorder8mb' => 'Archos FM Recorder 8MB',
           'ondiosp' => 'Archos Ondio SP',
           'ondiofm' => 'Archos Ondio FM',
           'h100' => 'iriver H100/115',
           'h120' => 'iriver H120/140',
           'h300' => 'iriver H320/340',
           'h10' => 'iriver H10 20GB',
           'h10_5gb' => 'iriver H10 5GB',
           'hdd1630' => 'Philips HDD1630',
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
           'iaudiom3' => 'iAudio M3',
           'sansae200' => 'SanDisk Sansa e200',
           'sansac200' => 'SanDisk Sansa c200',
           'sansaclip' => 'SanDisk Sansa Clip',
           'sansafuze' => 'SanDisk Sansa Fuze',
           'sansae200v2' => 'SanDisk Sansa e200 V2',
           'sansam200v4' => 'SanDisk Sansa m200 V4',
           'gigabeatf' => 'Toshiba Gigabeat F/X',
           'gigabeats' => 'Toshiba Gigabeat S',
           'mrobe100' => 'Olympus M-Robe 100',
           'mrobe500' => 'Olympus M-Robe 500',
           'creativezvm30' => 'Creative Zen Vision:M 30GB',
           'creativezvm60' => 'Creative Zen Vision:M 60GB',
           'creativezenvision' => 'Creative Zen Vision',
           'yh820' => 'Samsung YH-820',
           'yh920' => 'Samsung YH-920',
           'yh925' => 'Samsung YH-925',

           'install' => 'Windows Installer',
           'fonts' => 'Fonts',
           'source' => 'Source Archive');

# short name to docs name if the short name isn't already fine
%model2docs=(
        'recorder8mb' => 'recorder',
        'fmrecorder8mb' => 'fmrecorder',
        'ipodvideo64mb' => 'ipodvideo',
        'ipodmini1g' => 'ipodmini2g',
        'h120' => 'h100' );

# this is the default release version, see the table below for
# target specifics
$publicrelease="3.3";
$releasedate="June 19, 2009";
$releasenotes="/twiki/bin/view/Main/ReleaseNotes33";

%release=(
          'player' => "$publicrelease",
          'recorder'  => "$publicrelease",
          'recorder8mb'  => "$publicrelease",
          'fmrecorder'  => "$publicrelease",
          'fmrecorder8mb'  => "$publicrelease",
          'recorderv2'  => "$publicrelease",
          'ondiofm'  => "$publicrelease",
          'ondiosp'  => "$publicrelease",
          'iaudiom5'  => "$publicrelease",
          'iaudiox5'  => "$publicrelease",
          'h100'  => "$publicrelease",
          'h120'  => "$publicrelease",
          'h300'  => "$publicrelease",
          'h10_5gb'  => "$publicrelease",
          'h10'  => "$publicrelease",
          'ipod1g2g'  => "$publicrelease",
          'ipod3g'  => "$publicrelease",
          'ipod4gray'  => "$publicrelease",
          'ipodcolor'  => "$publicrelease",
          'ipodvideo'  => "$publicrelease",
          'ipodvideo64mb'  => "$publicrelease",
          'ipodmini1g'  => "$publicrelease",
          'ipodmini2g'  => "$publicrelease",
          'ipodnano'  => "$publicrelease",
          'gigabeatf'  => "$publicrelease",
          'sansae200'  => "$publicrelease",
          'sansac200'  => "$publicrelease",
          'mrobe100'  => "$publicrelease",
          'source'  => "$publicrelease",
          'fonts' => "$publicrelease"
          );

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
