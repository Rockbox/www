#define BGCOLOR "#b6c6e5"
#define MENUBG "#6887bb"
#define TITLE(_x) <h1>_x</h1>

#ifndef TWIKI
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<link rel="STYLESHEET" type="text/css" href="/style.css">
<link rel="shortcut icon" href="/favicon.ico">
#ifdef _PAGE_
<title>Rockbox - _PAGE_</title>
#else
<title>Rockbox</title>
#endif
<meta name="author" content="Rockbox Contributors">
#ifndef _PAGE_
<meta name="keywords" content="Rockbox,Archos,firmware,open source,computer,programming,software">
#endif
<script type="text/javascript">
function fsstrip() {
    var expr = /[0-9]+/;
    document.fsform.taskid.value = expr.exec(document.fsform.taskid.value);
    return true;
}
</script>
</head>
#else
%TMPL:DEF{"rockboxmenu"}%
#endif
<body>
<table border=0 cellpadding=7 cellspacing=0>
<tr valign="top">
<td bgcolor=MENUBG valign="top" rowspan=7 class='leftmenu'>
<br>
<div align="center"><a href="/">
<img src="/rockbox100.png" width=99 height=30 border=0 alt="Rockbox.org home"></a>
</div>
<div style="margin-top:20px">
<div class="submenu">
Downloads
</div>
<img width=16 height=16 src='/silk_icons/package.png' align='top'> <a class="menulink" href="/download/">releases</a><br>
<img width=16 height=16 src='/silk_icons/bomb.png' align='top'> <a class="menulink" href="http://build.rockbox.org">current build</a><br>
<img width=16 height=16 src='/silk_icons/style.png' align='top'> <a class="menulink" href="/wiki/RockboxExtras">extras</a><br>
<img width=16 height=16 src='/silk_icons/palette.png' align='top'> <a class="menulink" href="http://themes.rockbox.org/">themes</a>
<div class="submenu">
Documentation
</div>
<img width=16 height=16 src='/silk_icons/help.png' align='top'> <a class="menulink" href="/wiki/GeneralFAQ">FAQ</a><br>
<img width=16 height=16 src='/silk_icons/page_white_acrobat.png' align='top'> <a class="menulink" href="/manual.shtml">manual</a><br>
<img width=16 height=16 src='/silk_icons/application_edit.png' align='top'> <a class="menulink" href="/wiki/">wiki</a><br>
<img width=16 height=16 src='/silk_icons/book_open.png' align='top'> <a class="menulink" href="/wiki/DocsIndex">docs index</a>
<div class="submenu">
Support
</div>
<img width=16 height=16 src='/silk_icons/email.png' align='top'> <a class="menulink" href="/mail/">mailing lists</a><br>
<img width=16 height=16 src='/silk_icons/group.png' align='top'> <a class="menulink" href="/irc/">IRC</a><br>
<img width=16 height=16 src='/silk_icons/comment_edit.png' align='top'> <a class="menulink" href="http://forums.rockbox.org/">forums</a>
<div class="submenu">
Tracker
</div>
<img width=16 height=16 src='/silk_icons/bug.png' align='top'> <a class="menulink" href="/tracker/index.php?type=2">bugs</a><br>
<img width=16 height=16 src='/silk_icons/brick.png' align='top'> <a class="menulink" href="/tracker/index.php?type=4">patches</a><br>
<div class="submenu">
Search
</div>
<form id="fsform" action="/tracker/index.php" method="get" onSubmit="return fsstrip();">
<input id="taskid" name="show_task" type="text" size="10" maxlength="10" accesskey="t"><br>
<input class="mainbutton" type="submit" value="Flyspray #">
</form>
<br>
<form action="http://www.google.com/search">
<input name=as_q size=10><br>
<input value="Search" type=submit>
<input type=hidden name=as_sitesearch value="www.rockbox.org">
</form>
<p>
<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="585407">
<input type="image" src="/paypal-donate.gif" border="0" name="submit" alt="">
</form>
</div>

</td>
#ifdef TWIKI
<td bgcolor=MENUBG width=100%>%TMPL:END%
#else
<td class='rightcontent'>
#ifdef _LOGO_
_LOGO_
#else
TITLE(_PAGE_)
#endif
#endif
