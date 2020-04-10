#!/bin/sh

GITDIR="../rockbox_git_clone"
LAST_RELEASE="v3.15-final"

# recent mails  XXX FIXME
#perl last20threads.pl 5 1 > threads_front.html
#perl last20threads.pl 20 1 > threads.html

# recent wiki edits
perl recentwiki.pl 5 > recentwiki_front.html
perl recentwiki.pl 20 > recentwiki.html

GITLOG="git log --name-status --abbrev-commit --date=iso --encoding=iso-8859-1"

# recent commits
# ( cd $GITDIR && git pull -q )  # Now handled by cron
(cd $GITDIR && $GITLOG -5 ) | perl tools/gitlog2html.pl > last5front.html
(cd $GITDIR && $GITLOG -15 ) | perl tools/gitlog2html.pl > lastcode.html

# commits since last release
grep -v _PAGE_ head.html > since-release.html
(cd $GITDIR && $GITLOG "HEAD...$LAST_RELEASE") | perl tools/gitlog2html.pl >> since-release.html
cat foot.html >> since-release.html

# commits last four weeks
grep -v _PAGE_ head.html > since-4weeks.html
(cd $GITDIR && $GITLOG --since='4 weeks ago') | perl tools/gitlog2html.pl >> since-4weeks.html
cat foot.html >> since-4weeks.html
