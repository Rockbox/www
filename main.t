#define _LOGO_ <img src="rockbox400.png" align=center width=400 height=123>
#define _PAGE_ Open Source Jukebox Firmware
#define MAIN_PAGE
#include "head.t"

<h2>Purpose</h2>

<p>The purpose of this project is to write an Open Source replacement
firmware for the Archos Jukebox <i>5000</i>, <i>6000</i>, <i>Studio</i> and <i>Recorder</i> MP3 players.

<h2>News</h2>

<p><i>2002-09-19</i>: We now support multiple languages. You can help by translating Rockbox to your language. No programming skills required.
<a href="http://rockbox.haxx.se/mail/archive/rockbox-archive-2002-09/0856.shtml">See instructions here</a>

<p><i>2002-09-13</i>: We took a big step and converted to an entirely new font system for the Recorder. Please bear with us as we smoothen out the initial quirks.

<p><i>2002-09-03</i>: ROLO, the Rockbox Loader has been integrated into the CVS, allowing Archos or other Rockbox firmware being loaded by simply selecting the file!

<p><i>2002-09-02</i>: <a href="http://rockbox.haxx.se/tshirt-contest/vote.html">Vote for your favourite tshirt designs!</a>

<p><i>2002-08-28</i>: Version 1.3 is released. <a href="download/">Go fetch</a>.

<p><i><small>(Old news items have moved to a 
<a href="history.html">separate page</a>.)</small></i>

<h2>Recent CVS activity</h2>
<p>
<!--#include file="lastcvs.link" -->

<h2>Open bug reports</h2>
<p>
<!--#include file="bugs.txt" -->
<small><b>Note:</b> Don't file bug reports on daily builds. They are work in progress.</small>

<h2>Roadmap</h2>
<p>This is a rough indication of which features we plan/expect/hope to be
included in which versions. Naturally, this is all subject to change without
notice.

<dl>
<dt><b>Version 1.4</b>
<dd> Loadable fonts, Customizable WPS, Firmware loading (ROLO)
<dt><b>Version 2.0</b>
<dd> Recording, Autobuild playlists, File/directory management
</dl>

<h2>About the hardware</h2>

<p>I wrote a <a href="internals/bjorn.html">"dissection" page</a> some months ago,
showing the inside of the Archos and listing the main components.
I have also collected a couple of <a href="docs/">data sheets</a>.
Also, don't miss the <a href="notes.html">research notes</a>
from my reverse-engineering the firmware.

<h2>About the software</h2>

<p>The player has one version of the firmware in ROM.
The first thing this version does after boot is to look for a file called
"archos.mod" on the Player/Studio or "ajbrec.ajz" on the recorder in the
root directory of the harddisk. 
If it exists, it is loaded into RAM and started.
This is how firmware upgrades are loaded. Note that you can revert to the ROM
version by just deleting the firmware file.

#include "foot.t"
