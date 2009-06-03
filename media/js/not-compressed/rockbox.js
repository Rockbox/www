/*
 * Rockbox.org
 * rockbox.js
 * Copyright 2009 by Maciej "Macku" Adamczak <emacieka@tlen.pl>
 */
var playersList = new Hash( {
	'Apple': new Hash( {
		'iPod 1G': 'apple_ipod_1g.jpg',
		'iPod 2G': 'apple_ipod_2g.jpg',
		'iPod 3G': 'apple_ipod_3g.jpg',
		'iPod 4G': 'apple_ipod_4g.jpg',
		'iPod Mini 1G':    'apple_ipod_mini_1g.jpg',
		'iPod Mini 2G':    'apple_ipod_mini_2g.jpg',
		'iPod Nano 1G':    'apple_ipod_nano_1g.jpg',
		'iPod Photo':      'apple_ipod_photo.jpg',
		'iPod Video':      'apple_ipod_video.jpg'
	} ),

	'Archos': new Hash( {
		'Jukebox Player':   'archos_jukebox_player.jpg',
		'Jukebox Studio':   'archos_jukebox_studio.jpg',
		'Jukebox Recorder': 'archos_jukebox_recorder.jpg',
		'FM Recorder':      'archos_fm_recorder.jpg',
		'Ondio FM':         'archos_ondio_fm.jpg',
		'Ondio SP':         'archos_ondio_sp.jpg'
	} ),

	'Cowon': new Hash( {		
		'iAudio X5':  'cowon_iaudo_x5.jpg',
		'iAudio X5V': 'cowon_iaudo_x5v.jpg',
		'iAudio M5':  'cowon_iaudo_m5.jpg',
		'iAudio M5L': 'cowon_iaudo_m5l.jpg',
		'iAudio M3':  'cowon_iaudo_m3.jpg',
		'iAudio M3L': 'cowon_iaudo_m3l.jpg'
	} ),

	'iriver': new Hash( {
		'iriver H10':     'iriver_h10.jpg',
		'iriver H100':    'iriver_h100.jpg',
		'iriver H300':    'iriver_h300.jpg'
	} ),

	'Olympus': new Hash( {
		'M:Robe 100': 'olympus_mrobe_100.jpg'
	} ),

	'Sandisk': new Hash( {
		'Sansa c200':  'sandisk_sansa_c200.jpg',
		'Sansa e200':  'sandisk_sansa_e200.jpg',
		'Sansa e200R': 'sandisk_sansa_e200.jpg'
	} ),

	'Toshiba': new Hash( {
		'Gigabeat F':  'toshiba_gigabeat_f.jpg',
		'Gigabeat X':  'toshiba_gigabeat_x.jpg'
	} )
} );

// DO NOT EDIT BELOW
window.addEvent( 'load', function() {
	// Players lists
	if ( $('players_list' ) ) {
		new rockboxPlayersList();
	}

	// Subversion slider
	$( 'svn_container' ).slide( 'hide' ).setStyle( 'height', 'auto' );
	$( 'svn_slider' ).setStyle( 'height', 'auto' );

	$( 'svn_slider_handle' ).addEvent( 'click', function( event ) {
		event.preventDefault();

		$( 'svn_container' ).slide();
	} );

	// Announcement slider
	new noobSlide({
		box: $( 'announcements_slider' ),
		items: $$( '#announcements_slider div' ),
		size: 380,
		handles: $$( '#slider_handle span' ),
		fxOptions: {
			duration: 350
		},
		onWalk: function( currentItem, currentHandle ){
			this.handles.removeClass( 'selected' );
			currentHandle.addClass( 'selected' );
		}
	} );
} );