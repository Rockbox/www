#!/usr/bin/perl -w
use strict;
use POSIX;
use DBI;


my $baseurl = "https://www.rockbox.org";
my $htmldir = "/home/rockbox/www";

### flyspray
my $dbpath = 'DBI:mysql:rbflyspray';
my $dbuser = 'flyspray-ro';
my $dbpwd = 'fsro';

my $db = DBI->connect($dbpath, $dbuser, $dbpwd) or
    die "Failed opening db: $?";
#my $sth = $db->prepare("SELECT task_id,last_edited_time FROM flyspray_tasks WHERE is_closed=0 AND (task_type=2 OR task_type=4)");
my $sth = $db->prepare("SELECT flyspray_tasks.task_id, flyspray_tasks.last_edited_time, flyspray_comments.last_edited_time, flyspray_tasks.is_closed FROM flyspray_tasks, flyspray_comments WHERE (task_type=2 OR task_type=4) AND flyspray_comments.task_id = flyspray_tasks.task_id");
my $rows = $sth->execute();
my $flyspray;
my %tasktime;
my %closed;
while (1) {
    my @r = $sth->fetchrow_array;
    last if (not @r);
    my $t;
    my $id = $r[0];
    if ($r[1] > $r[2]) {
        $t = $r[1];
    }
    else {
        $t = $r[2];
    }

    if (not defined $tasktime{$id} or ($t > $tasktime{$id})) {
        $tasktime{$id} = $t;
    }
    $closed{$id} = $r[3];
}

for my $id (keys %tasktime) {
    my $timestring = strftime("%FT%T+01:00", localtime($tasktime{$id}));
    $flyspray .= sprintf "<url href='https://www.rockbox.org/tracker/task/$id' lastmod='$timestring' priority='0.%d' />\n", $closed{$id} ? 1 : 5;
}

### html
my $site;
# hourly
my @hourly = ( "index.shtml",
               "recent.shtml",
               "since-12months.html",
               "since-4weeks.html",
               "since34.html",
                );

for my $file (@hourly) {
    next if (not -f "$htmldir/$file");
    my $modtime = (stat("$htmldir/$file"))[9];
    my $timestring = strftime("%FT%T+01:00", localtime($modtime));
    $site .= "<url href='https://www.rockbox.org/$file' lastmod='$timestring' changefreq='hourly' priority='0.9' />\n";
}


# daily
my @daily = ( "daily.shtml",
              "manual.shtml",
              "irc/index.shtml",
              );

for my $file (@daily) {
    my $modtime = (stat("$htmldir/$file"))[9];
    my $timestring = strftime("%FT%T+01:00", localtime($modtime));
    $site .= "<url href='https://www.rockbox.org/$file' lastmod='$timestring' changefreq='daily' priority='0.9' />\n";
}

# static site html
my @htmlfiles =
    (
        "devcon/index.html",
        "devcon2006/agenda.html",
        "devcon2006/index.html",
        "devcon2006/index3.html",
        "devcon2007/index.html",
        "devcon2007/webcam.html",
        "devcon2008/index.html",
        "doom/index.html",
        "download/index.html",
        "history.html",
        "irc/cgiirc/index.html",
        "lock.html",
        "mail/etiquette.html",
        "nospam.html",
);

for my $file (@htmlfiles) {
    my $modtime = (stat("$htmldir/$file"))[9];
    if ($modtime) {
        my $timestring = strftime("%FT%T+01:00", localtime($modtime));
        $site .= "<url href='https://www.rockbox.org/$file' lastmod='$timestring' priority='0.9' />\n";
    }
}


# mail
my $maildir = "/home/rockbox/mailinglists/html";
my $mail;
opendir(DIR, "$maildir") or die "Failed opening maillist dir: $!\n";
for my $dir (readdir DIR) {
    if ($dir =~ /^rockbox/ and -d "$maildir/$dir") {
        $mail .= "<directory path='$maildir/$dir' url='$baseurl/mail/archive/$dir/'/>\n";
    }
}
closedir DIR;

# twiki
my $twikidir = "/home/rockbox/foswiki/data/Main";
my $twiki;
opendir(DIR, $twikidir) or die "Failed opening wiki dir: $!\n";
for my $file (readdir DIR) {
    if ($file =~ /(.+?)\.txt$/) {
        my $base = $1;
        my $modtime = (stat("$twikidir/$file"))[9];
        my $timestring = strftime("%FT%T+01:00", localtime($modtime));
        $twiki .= "<url href='https://www.rockbox.org/wiki/$base' lastmod='$timestring' changefreq='weekly' priority='0.8' />\n";
    }
}
closedir DIR;

# irc
my $ircdir = "/home/rockbox/download/irc-logs/";
my $irc;

open FLIST, "-|", "find $ircdir -name 'rockbox*.txt'" or
  die "Can't execute find: $!";

while (<FLIST>) {
  chomp;
  s/$ircdir(.*)/$1/;
  if (/rockbox-(.+?).txt/) {
      my $date = $1;
      my $modtime = (stat("$ircdir/$_"))[9];
      my $timestring = strftime("%FT%T+01:00", localtime($modtime));
      $irc .= "<url href='https://www.rockbox.org/irc/log-$date' lastmod='$timestring' changefreq='never' priority='0.2' />\n";
    }
}

close DIR;

# output config file
open CONFIG, ">sitemap_config.xml" or die "Failed creating sitemap_config.xml: $!";

print CONFIG <<END
<?xml version="1.0" encoding="UTF-8"?>
<site
  base_url="https://www.rockbox.org/"
  store_into="/home/rockbox/www/sitemap.xml.gz"
  verbose="0"
  sitemap_type="web"
>
$flyspray
$site
$mail
$twiki
$irc
</site>
END
    ;



close CONFIG;
