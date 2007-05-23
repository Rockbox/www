#define _PAGE_ Download
#define DOWNLOAD_PAGE
#include "head.t"

<h2>Latest version is 2.5 (2005-09-22)</h2>

<p>Please read the <a href="rockbox-2.5-notes.txt">release notes</a>. (<a href="old.html">Older releases</a>)

<big><p>Note: Version 2.5 was only released for Archos devices. For other devices, download a <a href="http://build.rockbox.org/">current build</a>.</big>

<p>Make sure you download the correct file for your device:
<table class=rockbox><tr>
<th>player</th>
<th>recorder</th>
<th>recorder v2</th>
<th>fm recorder</th>
</tr><tr valign=top>

<td><a href=/docs/newplayer.jpg><img border=0 src=/docs/newplayer_t.jpg></a><br clear=all>Archos Jukebox 5000, 6000 and Studio models
<p><a href="rockbox-2.5-player.zip">rockbox-2.5-player.zip</a>
<br>(452 KB)</td>

<td>
<a href=/docs/recorder.jpg><img border=0 src=/docs/recorder_t.jpg></a><br clear=all>Archos Jukebox Recorder 6, 10, 15 and 20
<p><a href="rockbox-2.5-recorder.zip">rockbox-2.5-recorder.zip</a>
<br>(736 KB)</td>

<td><a href=/docs/fmrecorder.jpg><img border=0 src=/docs/fmrecorder_t.jpg></a><br clear=all>Archos Jukebox Recorder V2
<p><a href="rockbox-2.5-recorderv2.zip">rockbox-2.5-recorderv2.zip</a>
<br>(744 KB)</td>

<td><a href=/docs/fmrecorder.jpg><img border=0 src=/docs/fmrecorder_t.jpg></a><br clear=all>Archos Jukebox FM Recorder
<p><a href="rockbox-2.5-fmrecorder.zip">rockbox-2.5-fmrecorder.zip</a>
<br>(744 KB)</td>

</tr><tr>
<th>ondio fm</th>
<th>ondio sp</th>
<th>installer</th>
</tr><tr>

<td><a href=/docs/ondiofm.jpg><img border=0 src=/docs/ondiofm_t.jpg></a><br clear=all>Archos Ondio 128 & 128 FM
<p><a href="rockbox-2.5-ondiofm.zip">rockbox-2.5-ondiofm.zip</a>
<br clear=all>(462 KB)</td>

<td><a href=/docs/ondiosp.jpg><img border=0 src=/docs/ondiosp_t.jpg></a><br clear=all>Archos Ondio 128 SP
<p><a href="rockbox-2.5-ondiosp.zip">rockbox-2.5-ondiosp.zip</a>
<br>(620 KB)</td>

<td><img border=0 src=/docs/install.png></a><br clear=all>Windows installer
<p><a href="rockbox-2.5-install.exe">rockbox-2.5-install.exe</a>
<br>(1.4 MB)</td>

</tr></table>

<h2>Installation</h2>

<p>Unpack the entire zip archive in the root (top) directory of your Archos disk. Make sure you stop/eject/unmount the usb disk before you unplug it. <b>Note:</b> All files in the zip file are needed, don't just install a few of them.

<p>Windows users can also use the the installer: Simply select your model and destination drive.

<h2>Download voice files</h2>
<ul>
<li><a href="/twiki/bin/view/Main/VoiceFiles">Voice files</a>
</ul>

<h2>Uninstallation</h2>

<p>If you ever want to remove the Rockbox firmware, simply delete archos.mod (player) or ajbrec.ajz (recorder) and the .rockbox directory from the root of your Archos disk.

<h2>Source code</h2>
<p><a href="rockbox-2.5.tar.gz">rockbox-2.5.tar.gz</a>
<p>
... or get the source directly off the <a href="/twiki/bin/view/Main/UsingSVN">SVN server</a>.

<h2>Manual</h2>

<p>We have a very nice <a href="/twiki/bin/view/Main/RockboxManual">manual</a>
written by Christi Scarborough. Please read it. Check out the <a
href="/twiki/bin/view/Main/DocsIndex">documentation</a> page for further info.
 
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

<h2>Bug reports</h2>

<p>Please use our <a href="/bugs.shtml">bug page</a>
for all bug reports and feature requests.

<p>If you are interested in helping with the development of Rockbox, please join the mailing list.

#include "foot.t"
