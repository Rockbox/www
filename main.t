#if 1
        #define _LOGO_ <img src="rockbox400.png" align=center width=400 height=123 alt="Rockbox Logo">
#else
        #define _LOGO_ <img src="rockboxdevconnz8.png" align=center width=400 height=123 alt="Rockbox devcon2007 Logo">

#endif
#define _PAGE_ Open Source Jukebox Firmware
#define MAIN_PAGE
#include "head.t"

<div class="sponsor">
<h2>Sponsors</h2>
<a href="http://www.contactor.se"><img border=0 src="/cont.png" width=101 height=36 alt="Contactor Data AB Logo"></a>
<br>Contactor Data AB sponsors bandwidth and server for the main site.
<br>
<a href="http://www.haxx.se"><img border=0 src="/haxx.png" width=80 height=34 alt="Haxx Logo"></a>
<br>
Haxx sponsors the download server and bandwidth, as well as various other resources
<p>
<form action="https://www.paypal.com/cgi-bin/webscr" method="post"><input type="hidden" name="cmd" value="_xclick"><input type="hidden" name="business" value="bjorn@haxx.se"><input type="hidden" name="item_name" value="Donation to the Rockbox project"><input type="hidden" name="no_shipping" value="1"><input type="hidden" name="cn" value="Note to the Rockbox team"><input type="hidden" name="currency_code" value="USD"><input type="hidden" name="tax" value="0"><input type="image" src="/paypal-donate.gif" border="0" name="submit"></form>
<span>Many people have sponsored us with personal Paypal donations. Thank you!</span>
</div>

<p class="ingress">
Rockbox is an open source replacement firmware for mp3 players. It runs on a number of different models:
<ul>
<li><b>Archos</b>: Jukebox 5000, 6000, Studio, Recorder, FM Recorder, Recorder V2
and Ondio
<li><b>iriver</b>: H100, H300 and H10 series

<li><b>Apple</b>: iPod 4th gen (grayscale and color), 5th/5.5th gen video, 1st
gen Nano and Mini 1st/2nd gen (<i>Nano 2nd gen is not supported</i>)

<li><b>Cowon</b>: iAudio X5 (including X5V and X5L), M5 (including M5L)

<li><b>Toshiba</b>: Gigabeat X and F series (<i>the S model is not supported</i>)

<li><b>SanDisk</b>: Sansa E200 series (<i>the R models are not supported</i>)

<li>Additional models are <a href="http://www.rockbox.org/twiki/bin/view/Main/TargetStatus">in development</a>


</ul>

<p> Rockbox is a complete rewrite and uses no fragments of any original
firmwares. <a href="/twiki/bin/view/Main/WhyRockbox">What is Rockbox?</a>.
Check the <a
href="http://www.rockbox.org/twiki/bin/view/Main/MajorChanges">changelog</a>
for recent changes.

<h2>News</h2>

<p><i>2007-05-23</i>: Rockbox works on the ipod video 5.5gen 80GB

<p><i>2007-05-18</i>: <a href="devcon2007/">Devcon 2007 took place</a>

<p><i>2007-05-06</i>: Scheduled server maintenance. build.rockbox.org and download.rockbox.org will be down approximately 00:00 to 10:00 CET.

<p><i>2007-03-29</i>: Announcing the <a href=http://www.rockbox.org/twiki/bin/view/Main/DevCon2007>Rockbox International Developers Conference 2007</a> to be
held in Stockholm May 19-20 2007.

<p><i>2007-03-15</i>: Rockbox has been accepted as a mentor organization of <a
href="http://www.rockbox.org/twiki/bin/view/Main/SummerOfCode">Google's summer
of code 2007</a>

<p><i><a href="history.html">Older news</a></i>

<h2>Recent SVN activity</h2>
<i><small>
   All commits <a href="since25.html">since 2.5</a>
   <a href="since20060801.html">since Aug 1st 2006</a>
   <a href="since-4weeks.html">during the last four weeks</a>
</small></i>
<p>
<!--#include file="lastcvs.link" -->

#include "foot.t"
