#!/bin/sh

rev=$1

cat data/$rev*.size > data/$rev.sizes

perl clientstats.pl $rev >> data/$rev-clients.html

perl showbuilds.pl > builds.html
perl showsize.pl > sizes.html
perl mktitlepics.pl
