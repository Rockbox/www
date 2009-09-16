#!/bin/sh

# since last release
grep -v _PAGE_  head.html > since33.html
( cd ../trunk && svn log -v -r HEAD:21336 ) | perl tools/svnlog2html.pl >> since33.html
cat foot.html >> since33.html

# last four weeks
grep -v _PAGE_  head.html > since-4weeks.html
( cd ../trunk && svn log -v -r "HEAD:{`date --date='28 days ago' +'%Y-%m-%d'`}" ) | perl tools/svnlog2html.pl >> since-4weeks.html
cat foot.html >> since-4weeks.html
