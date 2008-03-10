#if 1
        #define _LOGO_ <div style="max-width: 1000px;"><div align=center><img src="rockbox400.png" width=400 height=123 alt="Rockbox Logo"></div>
#else
        #define _LOGO_ <img src="rdcwlogo.png" align=center width=400 height=123 alt="Rockbox Devcon West 2007">

#endif
#define _PAGE_ Open Source Jukebox Firmware
#define MAIN_PAGE
#include "head.t"

<p><table class='blurb' align=center><tr><td>
<p class="ingress">
Rockbox is an open source firmware for mp3 players, written from scratch. It runs on a wide range of players:
<ul>

<li><b>Apple</b>: 1st through 5.5th generation iPod, iPod Mini and 1st
generation iPod Nano<br>(<i>not the Shuffle, 2nd/3rd gen Nano, Classic or
Touch</i>)

<li><b>Archos</b>: Jukebox 5000, 6000, Studio, Recorder, FM Recorder, Recorder V2
and Ondio
<li><b>Cowon</b>: iAudio X5, X5V, X5L, M5 and M5L

<li><b>iriver</b>: H100, H300 and H10 series

<li><b>SanDisk</b>: Sansa c200, e200 and e200R series (<i>not the v2 models</i>)

<li><b>Toshiba</b>: Gigabeat X and F series (<i>not the S series</i>)


<li>More players are <a href="http://www.rockbox.org/twiki/bin/view/Main/TargetStatus">in development</a>

</ul>

<p>Why should you run Rockbox? <a href="/twiki/bin/view/Main/WhyRockbox">Click here to find out</a>

</td></tr></table>

<!--
Check the <a
href="http://www.rockbox.org/twiki/bin/view/Main/MajorChanges">changelog</a>
for recent changes.
-->

<h2>Recent activity:</h2>

<table><tr valign="top"><td>

<h3 class=frontpage><a href='history.html'>Project news</a></h3>
<table class="news" summary="recent news">
<caption>Recent news</caption>
<tr class='tabletop'><th>when</th><th>what</th></tr>
<tr><td nowrap>2008-03-06</td><td>We're applying to participate in <a href="/wiki/SummerOfCode2008">Google's summer of code 2008</a>. </td></tr>
<tr><td nowrap>2007-11-23</td><td>New USB stack with limited capability. Currently it only requests full charging power. Ignore driver popups from Windows.</td></tr>
<tr><td nowrap>2007-11-18</td><td><a href="http://www.rockbox.org/mail/archive/rockbox-archive-2007-11/0176.shtml">New voice codec used:</a> Speex!</td></tr>
<tr><td nowrap>2007-09-19</td><td>1st and 2nd gen iPods are supported</td></tr>
<tr><td nowrap>2007-08-07</td><td>We now offer daily built voice files on the <a href="/daily.shtml">daily build page</a></td></tr>
<tr><td nowrap>2007-07-30</td><td>The <a href="http://www.rockbox.org/mail/archive/rockbox-dev-archive-2007-07/0049.shtml">Tracker Cleanup Week</a> has begun!</td></tr>
<!--
<tr><td colspan=2 align='center'><a href="history.html">Older news</a></td></tr>
-->
</table>

</td><td>

<h3 class=frontpage><a href='recent.shtml#wiki'>Wiki</a></h3>
<!--#include file="recentwiki_front.html" -->

</td></tr>

<tr><td colspan=2>

<h3 class=frontpage><a href='recent.shtml#svn'>Subversion</a></h3>
<!--#include file="last5front.html" -->
<small>All commits <a href="since25.html">since 2.5</a>,
 <a href="since-12months.html">last 12 months</a>,
 <a href="since-4weeks.html">last four weeks</a>.
</small>

</td></tr>
<tr><td colspan=2>

<h3 class=frontpage><a href='recent.shtml#mail'>Mail</a></h3>
<!--#include file="threads_front.html" -->

</td></tr>
</table>

<h2>Sponsors:</h2>
<table class=sponsors><tr valign="top">
<td>
<a href="http://www.contactor.se"><img border=0 src="/cont.png" width=101 height=36 alt="Contactor Data AB Logo"></a>
<p>Contactor Data AB sponsors bandwidth and server for the main site.
</td>

<td>
<a href="http://www.haxx.se"><img border=0 src="/haxx.png" width=80 height=34 alt="Haxx Logo"></a>
<p>
Haxx sponsors the build server, svn server and various other resources
</td>

<td>
<a href="http://www.videolan.org/"><img border=0 src="http://download.videolan.org/images/videolan-logo.png" width=100 height=47 alt="VideoLAN"></a>
<p>
VideoLAN sponsors a download server
</td>

<td>
<a href="http://www.positive-internet.com/"><img border=0
src="http://www.positive-internet.com/images/layout1_r1_c1.gif" width=52
height=70 alt="Positive Internet"></a>
<p>
Positive Internet sponsors a download server
</td>

<td>
<a href="http://www.tbrntech.com/">TBRN</a>
<p>
Beyond Technical Innovations sponsors a download server
</td>

<td>
<form action="https://www.paypal.com/cgi-bin/webscr" method="post"><input type="hidden" name="cmd" value="_xclick"><input type="hidden" name="business" value="bjorn@haxx.se"><input type="hidden" name="item_name" value="Donation to the Rockbox project"><input type="hidden" name="no_shipping" value="1"><input type="hidden" name="cn" value="Note to the Rockbox team"><input type="hidden" name="currency_code" value="USD"><input type="hidden" name="tax" value="0"><input type="image" src="/paypal-donate.gif" name="submit"></form>
<p>Many people have sponsored us with personal Paypal donations. Thank you!
</td>
</tr>
</table>
</div>

#include "foot.t"