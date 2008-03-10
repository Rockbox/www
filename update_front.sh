#!/bin/sh

# recent mails
perl last20threads.pl 5 1 > threads_front.html
perl last20threads.pl 20 1 > threads.html

# recent commits
( cd ~dast/src/rockbox && svn log -v --limit 5 ) | perl tools/svnlog2html.pl > last5front.html
( cd ~dast/src/rockbox && svn log -v --limit 15 ) | perl tools/svnlog2html.pl > lastsvn.html

# recent wiki edits
perl recentwiki.pl 5 > recentwiki_front.html
perl recentwiki.pl 20 > recentwiki.html
