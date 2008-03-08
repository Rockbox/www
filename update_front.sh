#!/bin/sh

# recent mails
perl last20threads.pl 5 1 > threads_front.html

# recent commits
( cd ~dast/src/rockbox && svn log -v --limit 5 ) | perl tools/svnlog2html.pl > last5front.html

# more commits
( cd ~dast/src/rockbox && svn log -v --limit 15 ) | perl tools/svnlog2html.pl > lastsvn.html

# recent wiki edits
perl recentwiki.pl 5 > recentwiki_front.html
