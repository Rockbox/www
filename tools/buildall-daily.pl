#!/usr/bin/perl
use POSIX 'strftime';
require './rockbox.pm';

# copy latest build from build farm to download server

while (-f "input/build_running") {
    # build in progress. wait for it to finish.
    sleep 10;
}

my @zips = `ls input/*.zip input/*tar.xz`;

my $date = strftime("%Y%m%d", localtime);
for (@zips) {
    chomp;
    if (/rockbox-(.+?)\.zip/) {
        my $model = $1;
        if (not -d "output/$model") {
            mkdir "output/$model";
            `chmod g+s output/$model`;
        }
        `cp $_ output/$model/rockbox-$model-$date.zip`;
        `chmod a+r output/$model/rockbox-$model-$date.zip`;
        `ln -sf rockbox-$model-$date.zip output/$model/rockbox-$model.zip`;
        #print "cp $_ output/$model/rockbox-$model-$date.zip\n";
    }
    if (/rockbox-(.+?)\.tar.xz/) {
        my $model = $1;
        if (not -d "output/$model") {
            mkdir "output/$model";
            `chmod g+s output/$model`;
        }
        `cp $_ output/$model/rockbox-$model-$date.tar.xz`;
        `chmod a+r output/$model/rockbox-$model-$date.tar.xz`;
        `ln -sf rockbox-$model-$date.tar.xz output/$model/rockbox-$model.tar.xz`;
        #print "cp $_ output/$model/rockbox-$model-$date.tar.xz\n";
    }
}

my @bleeding = `cat build-info`;
if ($bleeding[2] =~ /rev = \W*(\w+)/) {
    $rev = $1;
}

if (open OUT, ">output/build-info") {
    print OUT
        "[dailies]\n".
        "timestamp = \"$date\"\n".
        "rev = \"$rev\"\n";
        
    print OUT "[release]\n";
    for my $model (&stablebuilds) {
        if ($builds{$model}{'release'}) {
            print OUT "$model=$builds{$model}{'release'}\n";
        }
        else {
            print OUT "$model=$publicrelease\n";
        }
    }
    
    print OUT "[status]\n";
    for my $model (sort byname keys %builds) {
        print OUT "$model=$builds{$model}{\"status\"}\n";
    }
    
    close OUT;
}

if (open OUT, ">output/build-info-$date") {
    print OUT
        "[dailies]\n".
        "timestamp = \"$date\"\n".
        "rev = \"$rev\"\n";
    close OUT;

    # update build-info
    `cp "output/build-info-$date" "../download/build-info.daily"`;
    `(cd ../download ; . .scripts/mkbuildinfo.sh )`;
}
