<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" dir="ltr">
<head>
<title>Rockbox build round graphs</title>
<link rel="stylesheet" href="rockbox.css" />
<link rel="stylesheet" href="buildgraph.css" />
<style type="text/css">
</style>
</head>
</body>
<h1>Build round graphs</h1>
<table>
    <thead>
    <tr>
        <th>Date</th>
        <th>Revision</th>
        <th>Clients</th>
        <th>Duration</th>
        <th>Graphs</th>
    </tr>
    </thead>
<?php

$conn = mysqli_connect('localhost', 'buildmaster', 'JGQTcTPdPUcGsHb9');
if (!$conn) die("No connection to database (I'm aware of the issue)");
mysqli_select_db($conn, 'rbmaster');
$query = "
SELECT
    revision,
    UNIX_TIMESTAMP(time) as starttime,
    took as duration,
    clients as numclients
FROM rounds
WHERE time > 0
ORDER BY starttime DESC
";  // time > 0 gives us data from the start of the git era.
$res = mysqli_query($conn, $query);

if (mysqli_error($conn)) die("<!-- " . mysqli_error($conn) . " -->");
while ($row = mysqli_fetch_assoc($res)) {
    printf("  <tr>
    <td>%s</td>
    <td><a href=\"//git.rockbox.org/cgit/rockbox.git/commit/?id=%s\">%s</a></td>
    <td>%d</td>
    <td>%s</td>
    <td>
        <a href='graph.php?r=%2\$s'>Plain</a> - 
        <a href='graph.php?r=%2\$s&amp;debug'>Debug</a>
    </td>
  </tr>
",
        date('Y-m-d H:i:s', $row['starttime']),
        $row['revision'],
        $row['revision'],
        $row['numclients'],
        sprintf("%d:%02d", floor($row['duration'] / 60), $row['duration'] % 60)
    );
}

$query = "
SELECT
    revision,
    UNIX_TIMESTAMP(time) as starttime,
    took as duration,
    clients as numclients
FROM rounds
WHERE time = 0
ORDER BY revision DESC
";  // time > 0 gives us data from the start of the git era.  
$res = mysqli_query($conn, $query);

if (mysqli_error($conn)) die("<!-- " . mysqli_error($conn) . " -->");
while ($row = mysqli_fetch_assoc($res)) {
    printf("  <tr>
    <td align='center'> n/a </td>
    <td>r%s</a></td>
    <td>%d</td>
    <td>%s</td>
    <td>
        <a href='graph.php?r=%1\$s'>Plain</a> - 
        <a href='graph.php?r=%1\$s&amp;debug'>Debug</a>
    </td>
  </tr>
",
        $row['revision'],
        $row['numclients'],
        sprintf("%d:%02d", floor($row['duration'] / 60), $row['duration'] % 60)  
    );
}


?>
</table>

<hr />
<a href="http://www.rockbox.org">
  <img src="/rockbox/rockbox100.png" border="0" width="100" height="32" alt="www.rockbox.org" title="Rockbox - Open Source Jukebox Firmware" />
</a>
<small>Last updated <?php echo date('D M j H:i:s T Y', filemtime(__FILE__)); ?></small>
