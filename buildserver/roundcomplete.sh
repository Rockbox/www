#!/bin/sh

rev=$1

cat data/$rev*.size > data/$rev.sizes

grep -v _PAGE_ head.html > data/$rev-clients.html
perl clientstats.pl $rev >> data/$rev-clients.html
cat foot.html >> data/$rev-clients.html

perl showbuilds.pl > builds.html
perl showsize.pl > sizes.html
