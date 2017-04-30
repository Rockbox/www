#!/bin/sh

# recent mails
perl last20threads.pl 5 1 > threads_front.html
perl last20threads.pl 20 1 > threads.html

# recent wiki edits
perl recentwiki.pl 5 > recentwiki_front.html
perl recentwiki.pl 20 > recentwiki.html

GITLOG="git log --name-status --abbrev-commit --date=iso --encoding=iso-8859-1"

# recent commits
( cd ../trunk && git pull -q )
( cd ../trunk && $GITLOG -5 ) | perl tools/gitlog2html.pl > last5front.html
( cd ../trunk && $GITLOG -15 ) | perl tools/gitlog2html.pl > lastcode.html

# commits since last release
grep -v _PAGE_ head.html > since-release.html
( cd ../trunk && $GITLOG HEAD...c7d6457cfdd3d39aa669ed4b08e6bdf80182d9e9 ) | perl tools/gitlog2html.pl >> since-release.html
cat foot.html >> since-release.html

# commits last four weeks
grep -v _PAGE_ head.html > since-4weeks.html
( cd ../trunk && $GITLOG --since='4 weeks ago' ) | perl tools/gitlog2html.pl >> since-4weeks.html
cat foot.html >> since-4weeks.html

