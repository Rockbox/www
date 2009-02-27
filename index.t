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
generation iPod Nano<br>(<i>not the Shuffle, 2nd/3rd/4th gen Nano, Classic or
Touch</i>)

<li><b>Archos</b>: Jukebox 5000, 6000, Studio, Recorder, FM Recorder, Recorder V2
and Ondio
<li><b>Cowon</b>: iAudio X5, X5V, X5L, M5, M5L, M3 and M3L

<li><b>iriver</b>: H100, H300 and H10 series

<li><b>Olympus</b>: M:Robe 100

<li><b>SanDisk</b>: Sansa c200, e200 and e200R series (<i>not the AMS models</i>)

<li><b>Toshiba</b>: Gigabeat X and F series (<i>not the S series</i>)



</ul>

<p>Quick links:
<a href="/wiki/WhyRockbox">Why should you run Rockbox?</a>
&middot;
<a href="/wiki/MajorChanges">Change log</a>
&middot;
<a href="/wiki/TargetStatus">Status for current and work-in-progress targets</a>

</td></tr></table>

<h2>Recent activity:</h2>

<table><tr valign="top"><td>

<h3 class=frontpage><a href='history.html'>Project news</a></h3>
<table class="news" summary="recent news">
<caption>Recent news</caption>
<tr class='tabletop'><th>when</th><th>what</th></tr>
<tr><td nowrap>2009-02-25</td><td>The Rockbox USB stack is now enabled by default on <a href="http://forums.rockbox.org/index.php?topic=20752.0">all PP502x targets</a>.</td></tr>
<tr><td nowrap>2008-12-23</td><td><a href="http://www.rockbox.org/download">Rockbox 3.1 is released</a></td></tr>
<tr><td nowrap>2008-09-23</td><td><a href="http://www.rockbox.org/download">Rockbox 3.0 is released</a></td></tr>
<tr><td nowrap>2008-08-16</td><td><a href="http://www.rockbox.org/mail/archive/rockbox-dev-archive-2008-08/0032.shtml">Release 3.0 Feature Freeze</a></td></tr>
<tr><td nowrap>2008-06-29</td><td><a href="/devcon2008/">DevCon 2008</a> is over.</td></tr>
<tr><td nowrap>2008-03-17</td><td>We have been accepted as a mentor organization in <a href="/wiki/SummerOfCode2008">Google's summer of code 2008</a>. </td></tr>
<tr><td nowrap>2008-03-06</td><td>We're applying to participate in <a href="/wiki/SummerOfCode2008">Google's summer of code 2008</a>. </td></tr>
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
<small>All commits <a href="since30.html">since 3.0</a>,
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
