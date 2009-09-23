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

<p><h2>Stable ports</h2>
<p>Rockbox runs well on these players, has a complete manual and is supported by <a href="/download/">the installer</a>:
<ul>

<li><b>Apple</b>: 1st through 5.5th generation iPod, iPod Mini and 1st
generation iPod Nano<br>(<i>not the Shuffle, 2nd/3rd/4th gen Nano, Classic or
Touch</i>)

<li><b>Archos</b>: Jukebox 5000, 6000, Studio, Recorder, FM Recorder, Recorder V2
and Ondio
<li><b>Cowon</b>: iAudio X5, X5V, X5L, M5, M5L, M3 and M3L

<li><b>iriver</b>: iHP100 series, H100 series, H300 series and H10 series

<li><b>Olympus</b>: M:Robe 100

<li><b>SanDisk</b>: Sansa c200 series, e200 series and e200R series (<i>not the v2/AMS models</i>)

<li><b>Toshiba</b>: Gigabeat X and F series (<i>not the S series</i>)
</ul>

<h2>Unstable ports</h2>

<p>Rockbox runs on these players, but is incomplete, less usable or has problems that limit it to advanced users:

<ul>
<li><b>Cowon</b>: <a href="/wiki/CowonD2Info">D2</a>
<li><b>Olympus</b>: <a href="/wiki/OlympusMR500Info">M:Robe 500</a>
<li><b>Samsung</b>: <a href="/wiki/SamsungYH92xPort">YH-920</a> and <a href="/wiki/SamsungYH92xPort">YH-925</a>
<li><b>SanDisk</b>: <a href="/wiki/SansaAMS">Sansa e200 v2 (AMS)</a> and <a href="/wiki/SansaAMS">Sansa Fuze V1</a>
</ul>

<h2>Unusable ports</h2>
<p>Work has begun on porting Rockbox to these players, but much remains before they are usable:

<ul>
<li>Toshiba Gigabeat S, Cowon iAudio 7, Creative ZVM, Logik Dax, Meizu M6, Samsung YH820
<br>Philips GoGear HDD1600, HDD1800, HDD6300 and SA9200, Onda VX747 and VX767,
<br>Tatung Elio, Apple iPod Nano 2G, Sandisk Sansa m200, c100, Clip v1 and c200v2</a>
</ul>

<p>Click here for a <a href="/wiki/TargetStatus#New_Platforms_Currently_Under_De">status summary of unstable and unusable ports</a>.

<p>Quick links:
<a href="/wiki/WhyRockbox">Why should you run Rockbox?</a>
&middot;
<a href="/wiki/MajorChanges">Change log</a>
&middot;
<a href="/wiki/ContributingToRockbox">Contribute to Rockbox</a>


</td></tr></table>

<h2>Recent activity:</h2>

<table><tr valign="top"><td>

<h3 class=frontpage><a href='history.html'>Project news</a></h3>
<table class="news" summary="recent news">
<caption>Recent news</caption>
<tr class='tabletop'><th>when</th><th>what</th></tr>
<tr><td nowrap>2009-09-16</td><td>We moved the web site to a new server and migrated from twiki to foswiki.</td></tr>
<tr><td nowrap>2009-08-27</td><td>The site was offline for 50 hours when our ISP went down.</td></tr>
<tr><td nowrap>2009-06-21</td><td><a href="/wiki/DevConEuro2009">DevConEuro2009</a> has ended </td></tr>
<tr><td nowrap>2009-06-19</td><td><a href="http://www.rockbox.org/wiki/ReleaseNotes33">Rockbox 3.3 is released</a></td></tr>
<tr><td nowrap>2009-03-24</td><td><a href="http://themes.rockbox.org/">themes.rockbox.org</a> is available</td></tr>
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
<small>All commits <a href="since33.html">since v3.3</a>,
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
<a href="http://www.haxx.se"><img border=0 src="/haxx.png" width=80 height=34 alt="Haxx Logo"></a>
<p>
Haxx sponsors the main site, build server, svn server and various other resources
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
