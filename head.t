#ifndef TWIKI
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
#ifdef _PAGE_
                <title>Rockbox - _PAGE_</title>
#else
                <title>Rockbox &bull; open source jukebox firmware</title>
#endif
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="shortcut icon" href="http://www.rockbox.org/favicon.ico" />
		<link rel="stylesheet" href="/media/css/rockbox.css" type="text/css" />
		<script type="text/javascript" src="/media/js/mootools-1.2.1-core.js"></script>
		<script type="text/javascript" src="/media/js/mootools-1.2.1-more.js"></script>
		<script type="text/javascript" src="/media/js/rockbox.js"></script>
<script type="text/javascript">
function fsstrip() {
    var expr = /[0-9]+/;
    document.fsform.taskid.value = expr.exec(document.fsform.taskid.value);
    return true;
}
</script>
</head>

<body id="rock">
#else
%TMPL:DEF{"rockboxmenu"}%
#endif

		<div class="top_container">
			<div class="top wrapper">
				<ul class="menu">
					<li class="item home"><a href="/" class="selected"><em></em>Home</a></li>
					<li class="item download">
						<a href="#"><em></em>Downloads</a>
						<ul class="submenu">
							<li class="releases"><a href="/download/"><span class="icon"></span>Releases</a></li>
							<li class="build"><a href="http://build.rockbox.org"><span class="icon"></span>Current build</a></li>
							<li class="extras"><a href="/twiki/bin/view/Main/RockboxExtras"><span class="icon"></span>Extras</a></li>
							<li class="themes"><a href="http://themes.rockbox.org"><span class="icon"></span>Themes</a></li>
						</ul>
					</li>
					<li class="item documentation">
						<a href="#"><em></em>Documentation</a>
						<ul class="submenu">
							<li class="manual"><a href="/manual.shtml"><span class="icon"></span>Manual</a></li>
							<li class="faq"><a href="/twiki/bin/view/Main/GeneralFAQ"><span class="icon"></span>FAQ</a></li>
							<li class="wiki"><a href="/twiki/"><span class="icon"></span>Wiki</a></li>
						</ul>
					</li>
					<li class="item support">
						<a href="#"><em></em>Community</a>
						<ul class="submenu">
							<li class="mailing"><a href="/mail/"><span class="icon"></span>Mailing lists</a></li>
							<li class="irc"><a href="/irc/"><span class="icon"></span>IRC</a></li>
							<li class="forums"><a href="http://forums.rockbox.org"><span class="icon"></span>Forums</a></li>
						</ul>
					</li>
					<li class="item tracker">
						<a href="#"><em></em>Development</a>
						<ul class="submenu">
							<li class="dev"><a href="/dev.shtml"><span class="icon"></span>Developer page</a></li>
							<li class="bugs"><a href="/tracker/index.php?type=2"><span class="icon"></span>Bug tracker</a></li>
							<li class="patches"><a href="/tracker/index.php?type=2"><span class="icon"></span>Patch tracker</a></li>
						</ul>
					</li>
				</ul>

<!--
				<dl class="feeds">
					<dt class="news">
						<a href="#" title="Subscibe to last project news">Project news feeds</a>
					</dt>
					<dd>
						<a href="#">Project news</a>
					</dd>

					<dt class="subversion">
						<a href="#" title="Subscibe to last Subversion changes">Subversion feeds</a>
					</dt>
					<dd><a href="#" id="svn_slider_handle">Subversion</a></dd>

					<dt class="changes">
						<a href="#" title="Subscibe to last project major changes">Major changes feeds</a>
					</dt>
					<dd>
						<a href="#">Major changes</a>
					</dd>
				</dl>
-->
			</div>
		</div>


#ifndef FRONT_PAGE
		<div class="content_container">
			<div class="content wrapper">

#ifdef _PAGE_
<h1>_PAGE_</h1>
#endif
#endif

#ifdef TWIKI
%TMPL:END%
#endif
