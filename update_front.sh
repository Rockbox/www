#!/bin/sh

# recent mails
perl last20threads.pl 5 1 > threads_front.html
perl last20threads.pl 20 1 > threads.html

# recent commits
( cd ../trunk && svn up -q && svn log -v --limit 5 ) | perl tools/svnlog2html.pl > last5front.html
( cd ../trunk && svn log -v --limit 15 ) | perl tools/svnlog2html.pl > lastsvn.html

# recent wiki edits
perl recentwiki.pl 5 > recentwiki_front.html
perl recentwiki.pl 20 > recentwiki.html

# commits since last release
grep -v _PAGE_  head.html > since-release.html
( cd ../trunk && svn log -v -r HEAD:30927) | perl tools/svnlog2html.pl >> since-release.html
cat foot.html >> since-release.html

# commits last four weeks
grep -v _PAGE_  head.html > since-4weeks.html
( cd ../trunk && svn log -v -r "HEAD:{`date --date='28 days ago' +'%Y-%m-%d'`}" ) | perl tools/svnlog2html.pl >> since-4weeks.html
cat foot.html >> since-4weeks.html
