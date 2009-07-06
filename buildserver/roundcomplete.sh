#!/bin/sh

rev=$1

cat data/$rev*.size > data/$rev.sizes

perl showbuilds.pl > builds.html
perl showsize.pl > sizes.html
