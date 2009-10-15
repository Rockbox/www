#define _PAGE_ Daily builds
#include "head.t"

<h2>Daily Builds for Different Models</h2>

<p>These are automated daily builds of the current code. They contain all the
latest features. They may also contain bugs and/or undocumented changes... <a
href="/twiki/bin/view/Main/DeviceChart">identify your model</a>

<h2>Daily Build</h2>
<a name="target_builds"></a>
<a name="daily_builds"></a>
<!--#include virtual="dailymod.pl" -->

<h2>Donate</h2>

<p>If you enjoy using Rockbox, consider donating to the project. While we
develop the software in our spare time, equipment and players cost real money.
<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_xclick">
<input type="hidden" name="business" value="bjorn@haxx.se">
<input type="hidden" name="item_name" value="Donation to the Rockbox project">
<input type="hidden" name="no_shipping" value="1">
<input type="hidden" name="cn" value="Note to the Rockbox team">
<input type="hidden" name="currency_code" value="USD">
<input type="hidden" name="tax" value="0">
<input type="image" src="/paypal-donate.gif" border="0" name="submit">
</form>


#if 0
<h2>CVS Compile Status</h2>

<p>CVS code build status: number of compiler warnings the build generates. 0
(zero) means no warnings. The timestamp is GMT. <a
href="http://www.rockbox.org/twiki/bin/view/Main/TargetStatus">Target
Status</a>

<p>
<!--#include virtual="buildstatus.link" -->

<a name="bleeding_edge"></a>
<h2>Bleeding edge builds</h2>

<p>These builds are as "bleeding edge" as you can get. They are updated on
every source change. (See status on the first line in the above table).

<p>These are complete installation archives.

<p>

<a href="auto/build-player/rockbox.zip">Player</a>
<a href="auto/build-recorder/rockbox.zip">Recorder</a>
<a href="auto/build-ondiosp/rockbox.zip">Ondio SP</a>
<a href="auto/build-ondiofm/rockbox.zip">Ondio FM</a>
<a href="auto/build-fmrecorder/rockbox.zip">FM Recorder</a>
<a href="auto/build-recorderv2/rockbox.zip">V2 Recorder</a>
<a href="auto/build-recorder8mb/rockbox.zip">8MB Recorder</a>
<a href="auto/build-h100/rockbox.zip">iriver h100</a>
<a href="auto/build-h120/rockbox.zip">iriver h120</a>
<a href="auto/build-h300/rockbox.zip">iriver h300</a>
<a href="auto/build-ipodcolor/rockbox.zip">iPod Color</a>
<a href="auto/build-ipodnano/rockbox.zip">iPod Nano</a>
<a href="auto/build-ipod4gray/rockbox.zip">iPod 4G Gray</a>
<a href="auto/build-ipodvideo/rockbox.zip">iPod Video</a>
<a href="auto/build-source/rockbox-bleeding.tar.gz">source</a>

<p>
<a href="/twiki/bin/view/Main/UsingCVS">How to use CVS</a>.
#endif

#include "foot.t"
