<?php

$string = isset($_GET['s']) ? $_GET['s'] : "";

$labelname = sprintf("labels/%s.gif", md5($string));
if (!file_exists($labelname) || filemtime($labelname) < filemtime(__FILE__)) {
    
    $font = 3;
    $im = imagecreate(300, 15);
    $magicpink = imagecolorallocate($im, 255, 0, 255);
    $text = imagecolorallocate($im, 0,0,0);
    imagestring($im, $font, 2, 0, $string, $text);
    imagecolortransparent($im, $magicpink);
    header("Content-type: image/gif");
    imagegif($im, $labelname);
}
readfile($labelname);

?>
