#define _PAGE_ History
#define HISTORY_PAGE
#include "head.t"

<p><i>2002-07-28</i>: Configuration saving implemented for all models. Experimental saving to disk
is not yet enabled on the players by default.

<p><i>2002-06-30</i>: USB cable detection added.

<p><i>2002-06-27</i>: MP3 playback now works for Recorder 6000 and Recorder 10 too.

<p><i>2002-06-19</i>: Version 1.1 is released. <a href="download/">Download it here</a>.

<p><i>2002-06-19</i>: Recorder sound support checked into CVS. Good news: No background noise!

<p><i>2002-06-10</i>: Playlist and scroll support added. Testing for release v1.1.

<p><i>2002-06-07</i>: The ATA driver now works for the Recorder models too.

<p><i>2002-06-01</i>: Version 1.0 is released! <a href="download/">Download it here</a>.

<p><i>2002-06-01</i>: Web site has been down three days due to a major power loss.

<p><i>2002-05-27</i>: All v1.0 code is written, we are now entering debug phase.
If you like living on the edge, <a href="daily.shtml">here are daily builds</a>.

<p><i>2002-05-26</i>: New web design. First player release drawing closer.

<p><i>2002-05-03</i>: <b>SOUND!</b> Linus' experimental MAS code has 
<a href="http://bjorn.haxx.se/rockbox/mail/archive/rockbox-archive-2002-05/0016.shtml">played our first 4 seconds of music</a>.

<p><i>2002-04-27</i>: Julien Labruy�re has generously donated an Archos Jukebox 6000 to the project. Thank you!

<p><i>2002-04-25</i>: Grant Wier has tested the Player LCD's double-height capability:
<a href="archos-text-DH1.jpg"><img align=center src="archos-text-DH2_sm.jpg"></a>

<p><i>2002-04-23</i>: Report from the <a href="devcon/">Rockbox Spring Developer Conference 2002</a> ;-)

<p><i>2002-04-22</i>: Gentlemen, we have <a href="http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/rockbox/firmware/thread.c">threading</a>.

<p><i>2002-04-11</i>: The <a href="codes_rec.png">Recorder charset</a> has been mapped.

<p><i>2002-03-28</i>: Lots of new stuff on the web page:
<a href="docs/faq.html">faq</a>,
<a href="irc/">irc logs</a>,
<a href="tools.html">tools</a> and
<a href="internals/">photos</a>.

<p><i>2002-03-25</i>: New section for
<a href="mods/">hardware modifications</a>.
First out is the long awaited
<a href="mods/serialport.html">serial port mod</a>.

<p><i>2002-03-25</i>: New instructions for
<a href="cross-gcc.html">how to build an SH-1 cross-compiler</a>.

<p><i>2002-03-14</i>: New linux patch and instructions for 
<a href="lock.html">unlocking the archos harddisk</a> if you have the "Part. Error" problem.

<p><i>2002-03-08</i>: Uploaded a simple example, showing
<a href="example/">how to build a program for the Archos</a>.

<p><i>2002-03-05</i>: The 
<a href="lock.html">harddisk password lock problem is solved</a>!
Development can now resume at full speed!

<p><i>2002-01-29</i>: If you have feature requests or suggestions,
please submit them to our
<a href="http://sourceforge.net/projects/rockbox/">Sourceforge page</a>.

<p><i>2002-01-19</i>: Cool logo submitted by Thomas Saeys.

<p><i>2002-01-16</i>: The project now has a proper name: Rockbox. 
Logos are welcome! :-)
<br>Also, Felix Arends wrote a quick <a href="sh-win/">tutorial</a>
for how to get sh-gcc running under windows.

<p><i>2002-01-09</i>: Nicolas Sauzede 
<a href="mail/archive/rockbox-archive-2002-01/0096.shtml">found out</a>
how to 
<a href="mail/archive/rockbox-archive-2002-01/0099.shtml">display icons and custom characters</a> on the Jukebox LCD.

<p><i>2002-01-08</i>: The two LCD charsets have been 
<a href="notes.html#charsets">mapped and drawn</a>.

<p><i>2002-01-07</i>:
<a href="mail/archive/rockbox-archive-2002-01/0026.shtml">Jukebox LCD code</a>.
I have written a small test program that scrolls some text on the display.
You need
<a href="mail/archive/rockbox-archive-2002-01/att-0026/01-archos.mod.gz">this file</a>
for units with ROM earlier than 4.50 and
<a href="mail/archive/rockbox-archive-2002-01/att-0050/02-archos.mod.gz">this file</a>
for all others. (The files are gzipped, you need to unzip them before they will work.)

<p><i>2001-12-29</i>: Recorder LCD code. Gary Czvitkovicz knew the Recorder LCD controller since before and wrote some
<a href="mail/archive/rockbox-archive-2001-12/att-0145/01-ajbr_lcd.zip">code</a>
that writes text on the Recorder screen.

<p><i>2001-12-13</i>: First program 
<a href="mail/archive/rockbox-archive-2001-12/0070.shtml">released</a>!
A 550 bytes long 
<a href="mail/archive/rockbox-archive-2001-12/att-0070/01-archos.mod">archos.mod</a>
that performs the amazing magic of flashing the red LED. :-)

<p><i>2001-12-11</i>: Checksum algorithm solved, thanks to Andy Choi. A new "scramble" utility is available.

<p><i>2001-12-09</i>: Working my way through the setup code. The <a href="notes.html">notes</a> are being updated continously.

<p><i>2001-12-08</i>: Analyzed the exception vector table. See <a href="notes.html">the notes</a>. Also, a <a href="mail/">mailing list archive</a> is up.

<p><i>2001-12-07</i>:
 I just wrote this web page to announce descramble.c. 
I've disassembled one firmware version and looked a bit on the code, but no real analysis yet.
Summary: Lots of dreams, very little reality. :-)

#include "foot.t"
