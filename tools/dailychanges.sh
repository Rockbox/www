#!/bin/sh

base_dir=/home/rockbox
date=$1

if [ -z "$date" ]; then
  echo "provide a date!"
  exit
fi

GITLOG="git log --name-status --abbrev-commit --date=iso-local --encoding=utf8 --pretty=fuller"

plaindate=`date -d "$date" +"%Y%m%d"`
plaindateold=`date -d "$date 1 day ago" +"%Y%m%d"`

out="$base_dir/download/daily/changelogs/changes-$plaindate.html"

cd "$base_dir/download/daily/"
revb=`grep rev build-info-$plaindate | cut -f 2 -d'=' | tr -d ' "'`
reva=`grep rev build-info-$plaindateold | cut -f 2 -d'=' | tr -d ' "'`
cd - > /dev/null

if [ "a$reva" != "a$revb" ] ; then
  echo > "$out"
  cat ../www/head.html >> "$out"
  ( cd "$base_dir/rockbox_git_clone" && $GITLOG "$reva...$revb") | perl "$base_dir/www/tools/gitlog2html.pl" >> "$out"
  cat ../www/foot.html >> "$out"

  perl -pni -e "s/_PAGE_/Changes from $plaindateold to $plaindate (UTC)/;" "$out"
fi
