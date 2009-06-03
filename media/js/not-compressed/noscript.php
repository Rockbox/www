<?php
/*
 * Rockbox.org
 * noscript.php
 * Copyright 2009 by Maciej "Macku" Adamczak <emacieka@tlen.pl>
 */

$playersList = array(
	'Apple' => array(
		'iPod 1G', 'iPod 2G', 'iPod 3G', 'iPod 4G', 'iPod Mini 1G', 'iPod Mini 2G', 'iPod Nano 1G', 
		'iPod Photo', 'iPod Video'
	),
	'Archos' => array(
		'Jukebox Player', 'Jukebox Studio', 'Jukebox Recorder', 'FM Recorder', 'Ondio FM',
		'Ondio SP'
	),
	'Cowon' => array(
		'iAudio X5', 'iAudio X5V', 'iAudio M5', 'iAudio M5L', 'iAudio M3', 'iAudio M3L'
	),
	'iriver' => array(
		'iriver H10', 'iriver H100', 'iriver H300'
	),
	'Olympus' => array(
		'M:Robe 100'
	),
	'Sandisk' => array(
		'Sansa c200', 'Sansa e200', 'Sansa e200R'
	),

	'Toshiba' => array(
		'Gigabeat F', 'Gigabeat X'
	)
);

// DO NOT EDIT BELLOW

echo '<div style="overflow: auto; height: 74px; width: 585px; padding: 5px 0; padding-right: 10px;">';

foreach($playersList as $manufacture=>$players) {
	echo '<h4>'.$manufacture.'</h4>';
	echo '<p style="margin: 0 0 10px">';
	echo '<strong>'.implode('</strong>, <strong>',$players).'</strong></p>';
}

echo "</div>\r\n";
?>