#define _PAGE_ Repair Your LCD
#include "head.t"

<p>
Author: Peter van Hardenberg
<p>
My LCD screen broke, I know I'm not alone, so at dwihno's suggestion, I'm 
typing up this information so everyone else can benefit too.
<p>
Okay, your LCD is broken, but the 'box still works. Now what?
<h2>PART 1: Getting a new screen</h2>
<p>
You're going to need a new LCD, but odds are you don't have a clue where 
to get one.
<pre>
Part number: G112064-30
Manufacturer: Shing Yih Technologies, Taiwan
</pre>
<p>
Unless you're buying a few hundred, I don't think Shing Yih is going to 
listen to you. Instead, I recommend you shop at:
<p>
<a href="http://www.newmp3technology.com/">http://www.newmp3technology.com/</a>
<p>
For me, a replacement LCD was $24USD with shipping. (Archos wants $60 
minimum just to look at it.)

<h2>PART 2: Disassembling the Frame</h2>
<p>
This is written up well on the rockbox site, but you will need a #10 Torx 
bit (check your hardware store) and a small Phillip's head screwdriver to 
take the box apart.
<p>
<a href="http://rockbox.haxx.se/mods/disassemble.html">http://rockbox.haxx.se/mods/disassemble.html</a>

<h2>PART 3: Desoldering</h2>
<p>
There are a total of eight points you will need to desolder. They are 
three on each side of the metal frame holding the electronics, and two at 
the top end. The side points are structural, but the top two (which are on 
either side of the microphone) supply power to the hard drive. I am not 
going to tell you how to desolder a joint. That is up to you. I found it 
helpful to use a small tool to lift up the joints as I worked, seperating 
the side ones individually and then gradually working out the top ones. I 
certainly hope you are more competant at desoldering than I.
<p>
The two electronics boards inside the Archos are connected by a paralell 
connector, much like the one you find on the back of your hard drives, 
though without the cable. This is why even desoldered the boards will 
stick together. Carefully seperate the two boards. They are connected by 
several wires. Don't break them.
<p>
<b>NOTE</b>: The two connections at the top (by the microphone) have wires 
embedded in them. This won't make your life any easier.
<p>
<b>NOTE</b>: If you remove the tape in the battery compartment while you work, 
make sure you replace it with something afterwards! (A couple strips of 
simple scotch tape worked for me.)
<p>
BE CAREFUL not to break the end boards off while you work!
<p>
Again, the rockbox site has some handy pictures, though this section is 
for the non-recorder model and is a bit uninformative.
<p>
<a href="http://rockbox.haxx.se/mods/disassemble2.html">http://rockbox.haxx.se/mods/disassemble2.html</a>

<h2>PART 3: The New LCD</h2>
<p>
Remove the old LCD cable. There are two little clips (one on each side of 
the connector) that can be gently pushed out to free the strip connector. 
When you put the new LCD in, make sure you have the right orientation 
(duh) and also make sure the connection is tight before you clip it back 
down. This part is probably the easiest of the whole affair. Be careful 
with the plastic frame under the LCD, as it seems a bit fragile.

<h2>PART 4: Test!</h2>
<p>
Don't solder it all back together yet. Re-seat the top electronics board 
so the parallel connector is snug. (Watch out for those pins by the 
microphone! Now you can plug the unit into the AC adapter to see if the 
LCD works. You should get a message on the LCD saying "ATA Error" or 
something to that effect. This means the LCD is sitting correctly and you 
can proceed to reassemble. If not, go back to part 3.
<p>
<h2>PART 5: Resolder</h2>
<p>
UNPLUG the archos. (Just thought I'd better reiterate.)
<p>
Resolder the two top connections (the ones by the mic).
<p>
PLUG the archos back in. The hard drive should spin up. Nothing much more 
will happen until you put the batteries in though. (I think, I can't quite 
remember.)
<p>
Okay, good. Unplug the Archos again.
<p>
IMPORTANT: When you resolder the frame points, make sure you don't leave 
any pointy bits of solder poking into where the batteries run. I did, and 
they scraped the plastic off my batteries, shorted out against the frame, 
melted the inside of one of the bumpers a bit (smoking and smelling 
awfully) and just about scared me to death. This is also why you need to 
put the tape back on if you removed it.

<h2>PART 6: Reassemble the Archos!</h2>
<p>
Put the archos back together, taking care not to bend anything. The rubber 
bumpers are tricky, but I think there are some notes on the rockbox site 
about how to put them on the right way.
<p>
Victory at last! You're done! Now go to the rockbox site and update your 
firmware, I bet it's out of date!

<h2>CONCLUSION</h2>
<p>
In the end, this cost me much less than sending it in to someone 
qualified, but was also a hell of a lot scarier. I think I learned a few 
things about my Archos though, and I look forward to trying some of the 
other mods.
<p>
I'm sure there are people out there (real pros) who are horrified at what 
I have written. Please, correct any mistakes I have made in this document 
so future 'boxers don't have to go through the hours of stress and strain 
I did.

#include "foot.t"
