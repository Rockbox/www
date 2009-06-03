#define FRONT_PAGE
#include "head.t"

         <div class="frontpage">
		<div class="header_container">
			<div class="header wrapper">
				<div class="player_image" id="player_image"></div>
				<div class="players" id="players_list">
					<h2>Supported players</h2>
					<noscript><?php require('media/js/noscript.php' ) ?></noscript>
				</div>
				<div class="download">
					<h2>Start using Rockbox</h2>
					<a href="#" title="Download Rockbox Utility Installer" class="button utility">
						<strong>Download Installer</strong>
						<span>Rockbox Utility</span>
					</a>
					<a href="#" title="Download Rockbox Manual" class="button manual">
						<strong>Download Manual</strong>
						<span>Get Rockbox User Guide</span>
					</a>
				</div>
			</div>
		</div>

		<div class="content_container">
			<div class="content wrapper">
				<div class="welcome">
					<h1>What is Rockbox?</h1>
					<p class="intro">
						Rockbox is an open source replacement for the software that drives your digital 
						audio players.
					</p>

					<p>
						It has been in development since 2001 and receives new features, 
						tweaks and fixes every day to provide you with the best possible music listening 
						experience.
					</p>
					<p>
						Rockbox aims to be considerably more functional and efficient than your players
						stock firmware, while remaining easy to use and customizable.
                                        </p>
                                        <p> Rockbox is written by users, for users.
					</p>
				</div>

				<ul class="links">
					<li class="target_status">
						<h4><a href="#">Target status</a></h4>
						<p>The current status of Rockbox development on various players.</p>
					</li>

					<li class="feature_comparison">
						<h4><a href="#">Feature comparison</a></h4>
						<p>Check Rockbox vs. out-of-the-box firmware features comparision.</p>
					</li>
					<li class="buyers_guide">
						<h4><a href="#">Buyers guide</a></h4>
						<p>Want to buy a device that Rockbox is compatible with it?</p>
					</li>
				</ul>
				<ul class="links right">
					<li class="screenchots">
						<h4><a href="#">Screenshots</a></h4>
						<p>Screenshots of Rockbox in action.</p>
					</li>
					<li class="faq">
						<h4><a href="#">FAQ</a></h4>
						<p>Frequently asked questions about Rockbox.</p>
					</li>
					<li class="glossary">
						<h4><a href="#">Glossary</a></h4>
						<p>Catch up with the Rockbox project lingo.</p>
					</li>
				</ul>
			</div>
		</div>

		<div class="columns_container">
<!--
			<div class="columns wrapper">
				<div class="announcements">
					<h2>Announcements</h2>
					<div id="slider_mask">
						<div id="announcements_slider">
							<div class="announcement">
								<h4 class="title">Rockbox 3.2 is released</h4>
								<h5 class="date">23 March 2009</h5>
								<p>
									The Rockbox project is pleased to announce the immediate availability of
									Rockbox 3.2. Since the last release we've added preliminary support for 
									Apple's Ipod Accessory Protocol, which means that many accessories now 
									partly work.
								</p>
							</div>
							<div class="announcement">
								<h4 class="title">Second news title</h4>
								<h5 class="date">20 March 2009</h5>
								<p>
									Lorem ipsum dolor sit amet elit est, et orci vitae tellus
									porttitor vel, wisi.
								</p>
								<p>
									Integer quis neque. Sed porttitor. Aenean pellentesque ut,
									placerat ante. Phasellus ultrices, dui tincidunt molestie, neque
									vel pede. Cras ut arcu.
								</p>
								<p>
									Etiam malesuada augue a diam.
								</p>
							</div>
							<div class="announcement">
								<h4 class="title">Third news title</h4>
								<h5 class="date">5 March 2009</h5>
								<p>
									Lorem ipsum dolor sit amet elit est, et orci vitae tellus 
									porttitor vel, wisi. Integer quis neque. Sed porttitor.
								</p>
								<p>
									Aenean pellentesque ut, placerat ante. Phasellus ultrices, dui 
									tincidunt molestie, neque vel pede. Cras ut arcu. Etiam malesuada
									augue a diam.
								</p>
							</div>
							<div class="announcement">
								<h4 class="title">Fourth news title</h4>
								<h5 class="date">28 February 2009</h5>
								<p>
									Lorem ipsum dolor sit amet elit est, et orci vitae tellus 
									porttitor vel, wisi. Integer quis neque. Sed porttitor. Aenean 
									pellentesque ut, placerat ante. Phasellus ultrices, dui tincidunt
									molestie, neque vel pede. Cras ut arcu. Etiam malesuada augue a
									diam.
								</p>
							</div>
							<div class="announcement">
								<h4 class="title">Fifth news title</h4>
								<h5 class="date">1 January 2009</h5>
								<p>
									Lorem ipsum dolor sit amet elit est, et orci vitae tellus 
									porttitor vel, wisi. Integer quis neque. Sed porttitor. Aenean 
									pellentesque ut, placerat ante.
								</p>
								<p>
									Phasellus ultrices, dui tincidunt molestie, neque vel pede.
									Cras ut arcu. Etiam malesuada augue a diam.
								</p>
							</div>
						</div>
					</div>

					<ul class="pagination" id="slider_handle">
						<li class="first"><span class="selected" title="Change announcement">Announcement 1</span></li>
						<li class="second"><span title="Change announcement">Announcement 2</span></li>
						<li class="third"><span title="Change announcement">Announcement 3</span></li>
						<li class="fourth"><span title="Change announcement">Announcement 4</span></li>
						<li class="fifth"><span title="Change announcement">Announcement 5</span></li>
					</ul>
				</div>
			</div>
-->
		</div>

		<div class="ssponsors_container">
			<div class="ssponsors wrapper">
				<h2>Sponsors</h2>
				<dl>
					<dt class="ssponsor1"><a href="#" title="Contactor Data AB">Contactor Data AB</a></dt>
					<dt class="ssponsor4"><a href="#" title="The Positive Internet Company">The Positive Internet Company</a></dt>
					<dt class="ssponsor2"><a href="#" title="Haxx">Haxx</a></dt>
					<dt class="ssponsor3"><a href="#" title="VideoLAN">VideoLAN</a></dt>
					<dt class="ssponsor5"><a href="#" title="TBRNTech">TBRNTech</a></dt>
				</dl>
			</div>
		</div>
        </div>

#include "foot.t"
