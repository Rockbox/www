<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" dir="ltr">
<head>
<title>Rockbox build round graphs</title>
<link rel="stylesheet" href="rockbox.css" />
<link rel="stylesheet" href="buildgraph.css" />
<style type="text/css">
.build { height: {$buildheight}em; }
</style>
</head>
</body>
<h1>Build round graphs</h1>
<table>
    <thead>
    <tr>
        <th>Revision</th>
        <th>Clients</th>
        <th>Duration</th>
        <th>Graphs</th>
    </tr>
    </thead>
<?php

$conn = mysql_connect('buildmaster.rockbox.org', 'rockbox', '');
if (!$conn) die("No connection to database (I'm aware of the issue)");
mysql_select_db('rockbox', $conn);
$res = mysql_query("SELECT revision, UNIX_TIMESTAMP(MIN(time)) as starttime, UNIX_TIMESTAMP(MAX(time)) as endtime, UNIX_TIMESTAMP(MAX(time)) - UNIX_TIMESTAMP(MIN(time)) as duration, COUNT(DISTINCT(client)) as numclients FROM builds WHERE revision>=22222 GROUP BY revision ORDER BY revision DESC");
if (mysql_error()) die(mysql_error());
while ($row = mysql_fetch_assoc($res)) {
    printf("  <tr>\n    <td>r%d</td>\n    <td>%d</td>\n    <td>%s</td>\n    <td><a href='graph.php?r=%1\$d'>Plain</a> - <a href='graph.php?r=%1\$d&amp;debug'>Debug</a></td>\n  </tr>\n",
        $row['revision'],
        $row['numclients'],
        sprintf("%d:%02d", floor($row['duration'] / 60), $row['duration'] % 60),
        date('Y-m-d H:i:s', $row['starttime'])
    );
}

?>
</table>

<hr />
<a href="http://www.rockbox.org">
  <img src="/rockbox/rockbox100.png" border="0" width="100" height="32" alt="www.rockbox.org" title="Rockbox - Open Source Jukebox Firmware" />
</a>
<small>Last updated <?php echo date('D M j H:i:s T Y', filemtime(__FILE__)); ?></small>
