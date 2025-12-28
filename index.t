#if 0
        #define _LOGO_ <div style="max-width: 1000px;"><div align=center><img src="rb10years400.png" width=400 height=140 alt="Rockbox Logo"></div>
#endif
#if 1
	#define _LOGO_ <div style="max-width: 1000px;"><div align=center><img src="rockbox400.png" width=400 height=123 alt="Rockbox Logo"></div>
#else
        #define _LOGO_ <img src="rdcwlogo.png" align=center width=400 height=123 alt="Rockbox Devcon West 2007">
        #define _LOGO_ <div style="max-width: 1000px;"><div align=center><img src="rb10years400.png" width=400 height=140 alt="Rockbox Logo"></div>
#endif
#define _PAGE_ Free Music Player Firmware
#define MAIN_PAGE
#include "head.t"

<p><table class='blurb' align=center><tr><td>
<p class="ingress">
Rockbox is a free replacement firmware for digital music players. It runs on a wide range of players:

<p><h2>Stable ports</h2>
<p>Rockbox runs well on these players, has installation instructions, and most are supported by the Rockbox Utility:
<ul>

<li><b>AIGO</b>: <a href="/wiki/AIGOErosQK">Eros Q / Eros K</a> (aka HIFI WALKER H2, AGPTek H3, and Surfans F20)
<li><b>Apple</b>: iPod 1g through 6g (Classic), iPod Mini, iPod Nano 1g, iPod Nano 2g
<li><b>Agptek</b>: <a href="/wiki/AgptekRocker">Rocker (aka Benjie T6)</a>
<li><b>Archos</b>: Jukebox 5000, 6000, Studio, Recorder, FM Recorder, Recorder V2 and Ondio
<li><b>Cowon</b>: iAudio X5, X5V, X5L, M5, M5L, M3 and M3L

<li><b>Creative</b>: <a href="/wiki/CreativeZENMozaicPort">Zen Mozaic</a>,
<a href="/wiki/CreativeZENXFiPort">Zen X-Fi</a>,
<a href="/wiki/CreativeZENXFi3Port">Zen X-Fi 3</a> and
<a href="/wiki/CreativeZENXFiStylePort">Zen X-Fi Style</a>
<li><b>FiiO</b>: <a href="/wiki/FiioM3K">M3K</a>
<li><b>iriver</b>: iHP100 series, H100 series, H300 series and H10 series
<li><b>MPIO</b>: HD300
<li><b>Olympus</b>: M:Robe 100
<li><b>Packard Bell</b>: Vibe 500
<li><b>Philips</b>: <a href="/wiki/GoGearSA9200info">GoGear SA9200</a>, <a href="/wiki/GoGearHDD6330">GoGear HDD16x0</a> and <a href="/wiki/GoGearHDD6330">HDD63x0</a>
<li><b>Samsung</b>: YH-820, YH-920 and YH-925
<li><b>SanDisk</b>: Sansa c200, e200 and e200R series, Fuze and <a href="/wiki/SansaFuzePlusPort">Fuze+</a>, Clip, Clip+ and Clip Zip
<li><b>Shanling</b>: <a href="/wiki/ShanlingQ1Port">Q1</a>
<li><b>Toshiba</b>: Gigabeat X and F series
<li><b>xDuoo</b>: <a href="/wiki/XDuooX3">X3, <a href="/wiki/XDuooX3ii">X3ii</a>, and <a href="/wiki/XDuooX3ii">X20</a>
</ul>

<h2>Unstable ports</h2>

<p>Rockbox runs on these players, but is incomplete, less usable or has problems that limit it to advanced users:

<ul>
<li><b>Anbernic</b>: <a href="/wiki/AnbernicRGNanoPort">RG Nano</a></li>
<li><b>Creative</b>: <a href="/wiki/CreativeZENPort">Zen</a> and <a href="/wiki/CreativeZENXFi2Port">Zen X-Fi 2</a></li>
<li><b>Cowon</b>: <a href="/wiki/CowonD2Info">D2</a></li>
<li><b>HiFi E.T</b>: <a href="/wiki/HifietMAPort">MA9</a>, <a href="/wiki/HifietMAPort">MA8</a></li>
<li><b>HiFiMAN</b>: <a href="/wiki/HifimanPort">HM-601</a>, <a href="/wiki/HifimanPort">HM-602</a>, <a href="/wiki/HifimanPort">HM-603</a>, <a href="/wiki/HifimanPort">HM-801</a></li>
<li><b>Hiby</b>: <a href="/wiki/HibyPort">R1</a>, <a href="/wiki/HibyPort">R3ProII</a></li>
<li><b>iBasso</b>: <a href="/wiki/IBassoDXPort">DX50</a>, <a href="/wiki/IBassoDXPort">DX90</a></li>
<li><b>MPIO</b>: <a href="/wiki/MPIOHD200Port">HD200</a></li>
<li><b>Olympus</b>: <a href="/wiki/OlympusMR500Info">M:Robe 500</a></li>
<li><b>Samsung</b>: <a href="/wiki/SamsungYPR0">YP-R0</a>, <a href="/wiki/SamsungYPR1">YP-R1</a></li>
<li><b>SanDisk</b>: <a href="/wiki/SansaConnect">Sansa Connect</a></li>
<li><b>Sony</b>:
<a href="/wiki/SonyNWZE350">NWZ-E350</a>,
<a href="/wiki/SonyNWZE360Port">NWZ-E360</a>,
<a href="/wiki/SonyNWZE370Port">NWZ-E370</a>,
<a href="/wiki/SonyNWZE380">NWZ-E380</a>,
<a href="/wiki/SonyNWZE450">NWZ-E450</a>,
<a href="/wiki/SonyNWZE460">NWZ-E460</a>,
<a href="/wiki/SonyNWZE470">NWZ-E470</a>,
<a href="/wiki/SonyNWZE580">NWZ-E580</a>,
<a href="/wiki/SonyNWZA860">NWZ-A860</a>,
<a href="/wiki/SonyNWZA10">NWZ-A10</a>,
and <a href="/wiki/SonyNWA20">NW-A20</a> series.</li>
<li><b>Toshiba</b>: <a href="/wiki/GigabeatSPort">Gigabeat S</a></li>
<li><b>iHIFI</b>: 770, 770C, and 800</li>
</ul>

<h2>Unusable ports</h2>
<p>Work has begun on porting Rockbox to these players, but much remains before they are usable:

<ul>
<li><b>Creative</b>: Zen V</li>
<li><b>Onda</b>: VX747, VX767 and VX777</li>
<li><b>Nintendo</b>: 3DS</li>
<li><b>iHIFI</b>: 760 and 960</li>
<li><b>Google</b>: Android (4.4 and older only)</li>
<li><b>Rockchip</b>: rk27xx (generic)</li>
<li><b>Surfans</b>: F28</li>
</ul>

<p>Click here for a <a href="/wiki/TargetStatus#New_Platforms_Currently_Under_Development">status summary of unstable and unusable ports</a>.

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

<tr><td nowrap>2025-12-28</td><td>An "unstable" port to the <a href="/wiki/HibyPort">Hiby R1 and R3ProII</a> is now available!</td></tr>
<tr><td nowrap>2025-10-23</td><td>An experimental port to the Nintendo 3DS is now available!</td></tr>
<tr><td nowrap>2025-09-25</td><td>An <a href="https://portmaster.games/detail.html?name=rockbox">unofficial port</a> to Portmaster for retro gaming handhelds is now available!</td></tr>
<tr><td nowrap>2025-07-30</td><td>An "unstable" port to the <a href="https://anbernic.com/products/rg-nano">Anbernic RG Nano</a> is available!</td></tr>
<tr><td nowrap>2025-07-29</td><td>An <a href="https://www.reddit.com/r/innioasis/comments/1mdrsre/y1_rockbox_installation_guide_using_spflashtool/">unofficial port</a> to the <a href="https://www.innioasis.com/products/y1">Innioasis Y1</a> is now available!</td></tr>

</table>
<small><a href="history.html">Older news</a>

</td><td>

<h3 class=frontpage><a href='recent.shtml#wiki'>Wiki</a></h3>
<!--#include file="recentwiki_front.html" -->
</td></tr>

<tr><td colspan=2>

<h3 class=frontpage><a href='recent.shtml#code'>Code changes</a></h3>
<!--#include file="last5front.html" -->
<small>All commits <a href="since-release.html">since last release</a>,
 <a href="since-4weeks.html">last four weeks</a>,
</small>

</td></tr>
<tr><td colspan=2>

#if 1
<h3 class=frontpage><a href='recent.shtml#mail'>Mail</a></h3>
<!--#include file="threads_front.html" -->
#endif
</td></tr>
</table>

#if 0
<h2>Sponsors:</h2>
<table class=sponsors><tr valign="top">
<td align='center'>
<a href="https://www.haxx.se/"><img border=0 src="/haxx.png" width=90 height=31 alt="Haxx Logo"></a>
<p>
Haxx sponsors the main site, build server, svn server and various other resources
</td>

<td align='center'>

<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="BTE95P4QL87E4">
<input type="image" src="//www.rockbox.org/paypal-donate.gif" border="0" name="submit" alt="">
</form>
<p>Many people have sponsored us with personal Paypal donations. Thank you!
</td>
</tr>
</table>
#endif
</div>

#include "foot.t"
