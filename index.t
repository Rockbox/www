#if 1
        #define _LOGO_ <div style="max-width: 1000px;"><div align=center><img src="rb10years400.png" width=400 height=140 alt="Rockbox Logo"></div>
#else
        #define _LOGO_ <img src="rdcwlogo.png" align=center width=400 height=123 alt="Rockbox Devcon West 2007">

#endif
#define _PAGE_ Free Music Player Firmware
#define MAIN_PAGE
#include "head.t"

<p><table class='blurb' align=center><tr><td>
<p class="ingress">
Rockbox is a free replacement firmware for digital music players. It runs on a wide range of players:

<p><h2>Stable ports</h2>
<p>Rockbox runs well on these players, has a complete manual and is supported by <a href="/download/">the installer</a>:
<ul>

<li><b>Apple</b>: iPod 1g through 5.5g, iPod Mini, iPod Nano 1g and iPod Nano 2g

<li><b>Archos</b>: Jukebox 5000, 6000, Studio, Recorder, FM Recorder, Recorder V2
and Ondio
<li><b>Cowon</b>: iAudio X5, X5V, X5L, M5, M5L, M3 and M3L

<li><b>iriver</b>: iHP100 series, H100 series, H300 series and H10 series

<li><b>Olympus</b>: M:Robe 100

<li><b>Packard Bell</b>: Vibe 500

<li><b>SanDisk</b>: Sansa c200 (not v2), e200 and e200R series, Fuze, Clip and Clip+

<li><b>Toshiba</b>: Gigabeat X and F series
</ul>

<h2>Unstable ports</h2>

<p>Rockbox runs on these players, but is incomplete, less usable or has problems that limit it to advanced users:

<ul>
<li><b>Cowon</b>: <a href="/wiki/CowonD2Info">D2</a>
<li><b>MPIO</b>: <a href="/wiki/MPIOHD200Port">HD200</a>, <a href="/wiki/MPIOHD300Port">HD300</a>
<li><b>Olympus</b>: <a href="/wiki/OlympusMR500Info">M:Robe 500</a>
<li><b>Philips</b>: <a href="/wiki/GoGearSA9200info">GoGear SA9200</a>, <a href="/wiki/GoGearHDD6330">GoGear HDD16x0</a> and <a href="/wiki/GoGearHDD6330">HDD63x0</a>
<li><b>Samsung</b>: <a href="/wiki/SamsungYPR0">YP-R0</a>, <a href="/wiki/SamsungYH92xPort">YH-820</a>, <a href="/wiki/SamsungYH92xPort">YH-920</a> and <a href="/wiki/SamsungYH92xPort">YH-925</a>
<li><b>SanDisk</b>: <a href="/wiki/SansaAMS">Sansa c200v2 series</a> and <a href="/wiki/SansaClip#Sansa_Clip_Zip_port_status">Sansa Clip Zip</a>
<li><b>Toshiba</b>: <a href="/wiki/GigabeatSPort">Gigabeat S</a>
</ul>

<h2>Unusable ports</h2>
<p>Work has begun on porting Rockbox to these players, but much remains before they are usable:

<ul>
<li><b>Onda</b> VX747, VX767 and VX777</li>
<li><b>Sandisk</b> Sansa m200, Fuze+</li>
<li><b>Google</b> Android</li>
<li><b>HiFiMAN</b> HM-601/HM-602</li>
<li><b>Apple</b> iPod Classic</li>
<li><b>Rockchip</b> rk27xx</li>
</ul>

<p>Click here for a <a href="/wiki/TargetStatus#New_Platforms_Currently_Under_De">status summary of unstable and unusable ports</a>.

<p>Quick links:
<a href="/wiki/WhyRockbox">Why should you run Rockbox?</a>
&middot;
<a href="/wiki/MajorChanges">Change log</a>
&middot;
<a href="/wiki/ContributingToRockbox">Contribute to Rockbox</a>

<p>If your player is not listed above, then Rockbox does not run on it.

</td></tr></table>

<h2>Recent activity:</h2>

<table><tr valign="top"><td>

<h3 class=frontpage><a href='history.html'>Project news</a></h3>
<table class="news" summary="recent news">
<caption>Recent news</caption>
<tr class='tabletop'><th>when</th><th>what</th></tr>

<tr><td nowrap>2011-12-07</td><td><a href="http://www.rockbox.org/wiki/ReleaseNotes310">Rockbox 3.10 is released</a></td></tr>

<tr><td nowrap>2011-09-03</td><td><a href="http://www.rockbox.org/wiki/ReleaseNotes391">Rockbox 3.9.1 is released</a></td></tr>

<tr><td nowrap>2011-06-27</td><td><a href="http://www.rockbox.org/wiki/ReleaseNotes39">Rockbox 3.9 is released</a></td></tr>

<tr><td nowrap>2011-04-06</td><td><a href="http://www.rockbox.org/wiki/ReleaseNotes381">Rockbox 3.8.1 is released</a></td></tr>

</table>
<small><a href="history.html">Older news</a>

</td><td>

<h3 class=frontpage><a href='recent.shtml#wiki'>Wiki</a></h3>
<!--#include file="recentwiki_front.html" -->

</td></tr>

<tr><td colspan=2>

<h3 class=frontpage><a href='recent.shtml#svn'>Code changes</a></h3>
<!--#include file="last5front.html" -->
<small>All commits <a href="since-release.html">since last release</a>,
 <a href="since-4weeks.html">last four weeks</a>,
 <a href="http://cia.vc/stats/project/rockbox/.rss">RSS feed</a>,
 <a href="http://twitter.com/rockboxcommits">twitter feed</a>.
</small>

</td></tr>
<tr><td colspan=2>

<h3 class=frontpage><a href='recent.shtml#mail'>Mail</a></h3>
<!--#include file="threads_front.html" -->

</td></tr>
</table>

<h2>Sponsors:</h2>
<table class=sponsors><tr valign="top">
<td align='center'>
<a href="http://www.haxx.se/"><img border=0 src="/haxx.png" width=90 height=31 alt="Haxx Logo"></a>
<p>
Haxx sponsors the main site, build server, svn server and various other resources
</td>

<td align='center'>
<form action="https://www.paypal.com/cgi-bin/webscr" method="post"><input type="hidden" name="cmd" value="_xclick"><input type="hidden" name="business" value="bjorn@haxx.se"><input type="hidden" name="item_name" value="Donation to the Rockbox project"><input type="hidden" name="no_shipping" value="1"><input type="hidden" name="cn" value="Note to the Rockbox team"><input type="hidden" name="currency_code" value="USD"><input type="hidden" name="tax" value="0"><input type="image" src="/paypal-donate.gif" name="submit"></form>
<p>Many people have sponsored us with personal Paypal donations. Thank you!
</td>
</tr>
</table>
</div>

#include "foot.t"
