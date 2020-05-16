#define BGCOLOR "#b6c6e5"
#define MENUBG "#6887bb"
#define TITLE(_x) <h1>_x</h1>

#ifndef TWIKI
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "//www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="STYLESHEET" type="text/css" href="//www.rockbox.org/style.css">
<link rel="shortcut icon" href="//www.rockbox.org/favicon.ico">
#ifdef _PAGE_
<title>Rockbox - _PAGE_</title>
#else
<title>Rockbox</title>
#endif
<meta name="author" content="Rockbox Contributors">
#ifndef _PAGE_
<meta name="keywords" content="Rockbox,Archos,firmware,open source,computer,programming,software">
#endif

#ifdef FLATTR
<script type="text/javascript">
function fsstrip() {
    var expr = /[0-9]+/;
    document.fsform.taskid.value = expr.exec(document.fsform.taskid.value);
    return true;
}

(function() {
    var s = document.createElement('script'), t = document.getElementsByTagName('script')[0];
    s.type = 'text/javascript';
    s.async = true;
    s.src = 'https://api.flattr.com/js/0.6/load.js?mode=auto';
    t.parentNode.insertBefore(s, t);
})();
#endif

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
<div align="center"><a href="//www.rockbox.org/">
<img src="//www.rockbox.org/rockbox100.png" width=99 height=30 border=0 alt="Rockbox.org home"></a>
</div>
<div style="margin-top:20px">
<div class="submenu">
Downloads
</div>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/package.png' align='top'> <a class="menulink" href="//www.rockbox.org/download/">release</a><br>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/bomb.png' align='top'> <a class="menulink" href="//build.rockbox.org">dev builds</a><br>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/style.png' align='top'> <a class="menulink" href="//www.rockbox.org/wiki/RockboxExtras">extras</a><br>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/palette.png' align='top'> <a class="menulink" href="http://themes.rockbox.org/">themes</a>
<div class="submenu">
Documentation
</div>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/page_white_acrobat.png' align='top'> <a class="menulink" href="//www.rockbox.org/manual.shtml">manual</a><br>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/application_edit.png' align='top'> <a class="menulink" href="//www.rockbox.org/wiki/">wiki</a><br>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/book_open.png' align='top'> <a class="menulink" href="//www.rockbox.org/wiki/TargetStatus">device status</a>
<div class="submenu">
Support
</div>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/comment_edit.png' align='top'> <a class="menulink" href="http://forums.rockbox.org/">forums</a><br>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/email.png' align='top'> <a class="menulink" href="//www.rockbox.org/mail/">mailing lists</a><br>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/group.png' align='top'> <a class="menulink" href="//www.rockbox.org/irc/">IRC</a>
<div class="submenu">
Development
</div>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/bug.png' align='top'> <a class="menulink" href="//www.rockbox.org/tracker/index.php?type=2">bugs</a><br>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/brick.png' align='top'> <a class="menulink" href="http://gerrit.rockbox.org">patches</a><br>
<img width=16 height=16 src='//www.rockbox.org/silk_icons/help.png' align='top'> <a class="menulink" href="//www.rockbox.org/wiki/DevelopmentGuide">dev guide</a>
<div class="submenu">
Search
</div>
<form id="fsform" action="//www.rockbox.org/tracker/index.php" method="get" onSubmit="return fsstrip();">
<input id="taskid" name="show_task" type="text" size="10" maxlength="10" accesskey="t"><br>
<input class="mainbutton" type="submit" value="Flyspray #">
</form>
<br>
<form action="//www.google.com/search">
<input name=as_q size=10><br>
<input value="Web pages" type=submit>
<input type=hidden name=as_sitesearch value="www.rockbox.org">
</form>

<div class="submenu">
Donate
</div>
<p>
<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="BTE95P4QL87E4">
<input type="image" src="//www.rockbox.org/paypal-donate.gif" border="0" name="submit" alt="">
</form>

#ifdef FLATTR
<p><a class="FlattrButton" style="display:none;" rev="flattr;button:compact;" href="//www.rockbox.org"></a>
#endif

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
