<?php

function clientnamesort($a, $b) {
    $a = strtolower(substr($a, strrpos($a, '-') + 1) . '-' . substr($a, 0, strrpos($a, '-')));
    $b = strtolower(substr($b, strrpos($b, '-') + 1) . '-' . substr($b, 0, strrpos($b, '-')));
    if ($a == $b)
        return 0;
    return $a > $b ? 1 : -1;
}

function buildsort($a, $b) {
    if ($a['start'] == $b['start']) return 0;
    return $a['start'] > $b['start'] ? 1 : -1;
}

function debugbuildsort($a, $b) {
    $aisqueued = ($a['type'] == 'queued' || $a['type'] == 'dequeued');
    $bisqueued = ($b['type'] == 'queued' || $b['type'] == 'dequeued');
    if ($aisqueued XOR $bisqueued) return $aisqueued ? -1 : 1;

    if ($a['start'] == $b['start']) return 0;
    return $a['start'] > $b['start'] ? 1 : -1;
}

function queuedsort($a, $b) {
    if ($a['order'] == $b['order']) return 0;
    return $a['order'] > $b['order'] ? 1 : -1;
}

class grapher {
    var $conn;

    function connect() {
        $this->conn = mysqli_connect('localhost', 'buildmaster', 'JGQTcTPdPUcGsHb9');
        if (!$this->conn) die("No connection to database (I'm aware of the issue)");
        mysqli_select_db($this->conn, 'rbmaster');
        return true;
    }

    function get_results($revision) {
        $res = mysqli_query($this->conn, sprintf("SELECT revision,client,id,ultime,ulsize,errors,warnings,ramsize,binsize,UNIX_TIMESTAMP(time) as end,UNIX_TIMESTAMP(time - INTERVAL timeused SECOND - INTERVAL ultime SECOND) as start FROM builds WHERE revision = '%s' ORDER BY client, start", 
            mysqli_real_escape_string($this->conn, $revision)));
        if (mysqli_num_rows($res) == 0)
            return false;

        $roundstart = PHP_INT_MAX;
        $roundend = -1;
        $round = array(
            'info' => array(
                'revision' => $revision,
                'roundstart' => PHP_INT_MAX,
                'roundend' => -1,
                'builds' => 0,
                'clients' => 0,
            ),
            'clients' => array()
        );

        while ($row = mysqli_fetch_assoc($res)) {
            $round['info']['roundstart'] = min($round['info']['roundstart'], $row['start']);
            $round['info']['roundend'] = max($round['info']['roundend'], $row['end']);
            if (!isset($round['clients'][$row['client']])) {
                $round['clients'][$row['client']] = array();
                $round['info']['clients']++;
            }

            if (substr($row['id'], -3) == 'sim')
                $row['type'] = 'sim';
            elseif (substr($row['id'], -4) == 'boot')
                $row['type'] = 'boot';
            elseif (substr($row['id'], -3) == 'wps')
                $row['type'] = 'wps';
            else
                $row['type'] = 'target';

            $round['clients'][$row['client']][] = $row;
            $round['info']['builds']++;
        }
        $round['info']['duration'] = $round['info']['roundend'] - $round['info']['roundstart'];

        uksort($round['clients'], 'clientnamesort');
        foreach ($round['clients'] as $client => &$builds) {
            usort($builds, 'buildsort');
            foreach ($builds as &$build) {
                $build['end'] -= $round['info']['roundstart'];
                $build['start'] -= $round['info']['roundstart'];
            }
        }
        return $round;
    }

    function get_debug_results($revision) {
        $of = sprintf('data/%d.debug-data', $revision);
        if (file_exists($of) && filemtime(__FILE__) < filemtime($of) && !isset($_GET['reload'])) {
            print("<!-- Getting from cache -->\n");
            return unserialize(file_get_contents($of));
        }
        @unlink($of);

        print("<!-- Fetching build round data -->\n");
        // ORDER BY time, type, because build events must come first. Luckily we have no events starting with a.
        $res = mysqli_query($this->conn, sprintf("SELECT client, UNIX_TIMESTAMP(time) AS time, type, value FROM log WHERE revision='%s' AND (client='w1ll14m-w1ll14m' OR 1) ORDER BY time, FIELD(type, 'queued', 'dequeued', 'build', 'uploading', 'cancelled', 'abandoned', 'disconnect', 'joined', 'completed')", 
            mysqli_real_escape_string($this->conn, $revision)));
        if (mysqli_num_rows($res) == 0) {
            echo "hej";
            return false;
        }
        $roundstart = PHP_INT_MAX;
        $roundend = -1;
        $round = array(
            'info' => array(
                'revision' => $revision,
                'roundstart' => PHP_INT_MAX,
                'roundend' => -1,
                'builds' => 0,
                'clients' => 0,
            ),
            'clients' => array()
        );
        $builtby = array();

        while ($row = mysqli_fetch_assoc($res)) {
            switch($row['type']) {
                case 'queued':
                    $v = explode(":", $row['value']);
                    $round['clients'][$row['client']]['queued'][$v[1]] = array(
                        'type' => 'queued',
                        'id' => $v[1],
                        'order' => $v[0],
                        'end' => $v[2],
                        'ultime' => max(0, $v[3]),
                        'start' => $row['time'],
                    );
                    break;
                case 'dequeued':
                    $round['clients'][$row['client']]['queued'][$row['value']]['type'] = 'dequeued';
                    $round['clients'][$row['client']]['queued'][$row['value']]['dequeued'] = $row['time'];
                    break;
                case 'build':
                    //printf("[%s] %s %s %s\n", date("H:i:s", $row['time']), $row['client'], $row['type'], $row['value']);
                    if (isset($round['clients'][$row['client']]['built'][$row['value']])) {
                        printf("AAAAAAAAAAAAAA %s is already building %s</xmp>", $row['client'], $row['value']);
                        print_r($round['clients'][$row['client']]);
                        die();
                    }
                    $round['clients'][$row['client']]['building'][$row['value']] = array(
                        'id' => $row['value'],
                        'start' => $row['time'],
                    );
                    break;
                case 'uploading':
                    //printf("[%s] %s %s %s\n", date("H:i:s", $row['time']), $row['client'], $row['type'], $row['value']);                    
                    $round['clients'][$row['client']]['building'][$row['value']]['ulstart'] = $row['time'];
                    break;
                case 'completed':
                    $round['info']['builds']++;
                    $v = explode(" ", $row['value']);
                    //printf("[%s] %s done building %s\n", date("H:i:s", $row['time']), $row['client'], $v[0]);
                    $round['clients'][$row['client']]['building'][$v[0]]['end'] = $row['time'];
                    $round['clients'][$row['client']]['building'][$v[0]]['type'] = $row['type'];
                    $round['clients'][$row['client']][$row['type']][] = $round['clients'][$row['client']]['building'][$v[0]];
                    unset($round['clients'][$row['client']]['building'][$v[0]]);
                    $builtby[$v[0]] = $row['client'];
                    break;
                case 'disconnect':
                    //printf("[%s] Disconnect by %s!\n", date("H:i:s", $row['time']), $row['client']);
                    //die();
                    break;
                case 'abandoned':
                case 'cancelled':
                    if (!isset($round['clients'][$row['client']]['building'][$row['value']])) break;
                    //printf("[%s] %s %s build %s\n", date("H:i:s", $row['time']), $row['type'], $row['client'], $row['value']);
                    $round['clients'][$row['client']]['building'][$row['value']]['start'] = $row['time'] - $row['ultime'];
                    $round['clients'][$row['client']]['building'][$row['value']]['end'] = $row['time'];
                    $round['clients'][$row['client']]['building'][$row['value']]['type'] = $row['type'];
                    $round['clients'][$row['client']][$row['type']][] = $round['clients'][$row['client']]['building'][$row['value']];
                    unset($round['clients'][$row['client']]['building'][$row['value']]);
                    break;
                case 'joined':
                    break;
                default:
                    die("Unknown type: ".$row['type']);
                    break;
            }
            $round['info']['roundend'] = max($round['info']['roundend'], $row['time']);
            $round['info']['roundstart'] = min($round['info']['roundstart'], $row['time']);
        }
        $round['info']['clients'] = count($round['clients']);
        
        $round['info']['duration'] = $round['info']['roundend'] - $round['info']['roundstart'];
        uksort($round['clients'], 'clientnamesort');

        foreach ($round['clients'] as $client => &$builds) {
            /* Order and fix up the queued builds */
            if (isset($builds['queued'])) {
                uasort($builds['queued'], 'queuedsort');
                $lastend =- $round['info']['roundstart'];
                foreach($builds['queued'] as &$build) {
                    /* Start time is the end time of the last build
                     * $build['start'] = the time the build was scheduled (usually be same as $roundstart)
                     */
                    $build['start'] = max($build['start'], $lastend);
                    $build['end'] += $build['start'];
                    $build['end'] += $build['ultime'];
                    $lastend = $build['end'] - $build['ultime'];
                }
            }
            
            $temp = array();
            foreach($builds as $type => $typebuilds) {
                foreach($typebuilds as $typebuild) {
                    $temp[] = $typebuild;
                }
                unset($builds[$type]);
            }
            $builds = $temp;
            foreach($builds as &$fixbuild) {
                if (isset($fixbuild['ulstart'])) {
                    $fixbuild['ultime'] = $fixbuild['end'] - $fixbuild['ulstart'];
                    unset($fixbuild['ulstart']);
                }
                if (isset($fixbuild['dequeued'])) {
                    $fixbuild['dequeued'] -= $round['info']['roundstart'];
                    $fixbuild['builtby'] = $builtby[$fixbuild['id']];
                }
                if ($fixbuild['type'] == 'cancelled') {
                    $fixbuild['builtby'] = $builtby[$fixbuild['id']];
                }
                $fixbuild['end'] -= $round['info']['roundstart'];
                $fixbuild['start'] -= $round['info']['roundstart'];
            }
            usort($builds, 'debugbuildsort');
        }

        file_put_contents($of, serialize($round));
        return $round;
    }

    function gantt_chart($round) {
        if ($round['info']['builds'] == 0) {
            die("This build '$revision' is not in the db");
        }
        $width = 40;
        $unit = 'em';
        $buildheight = isset($_GET['h']) ? sprintf("%f", $_GET['h']) : 1;
        $startdate = date('Y-m-d H:i:s', $round['info']['roundstart']);
        $enddate = date('Y-m-d H:i:s', $round['info']['roundend']);
        $duration = sprintf("%d:%02d", floor($round['info']['duration'] / 60), $round['info']['duration'] % 60);
        echo <<<HEADER
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" dir="ltr">
<head>
<title>Rockbox build round for r{$round['info']['revision']}</title>
<link rel="stylesheet" href="rockbox.css" />
<link rel="stylesheet" href="buildgraph.css" />
<style type="text/css">
.build { height: {$buildheight}em; }
</style>
</head>
</body>
<h1>Build round for r{$round['info']['revision']}</h1>

HEADER;
        
        if (isset($_GET['debug'])) {
            print("<p>This page lists all builds, including queued and killed in the build round.</p>\n");
        }
        else {
            print("<p>This page lists completed builds in the build round.</p>");
        }
        
        echo <<<HEADER
<table>
  <tr>
    <th>Round start</th>
    <td>$startdate</td>
  </tr>
  <tr>
    <th>Round end</th>
    <td>$enddate</td>
  </tr>
  <tr>
    <th>Round duration</th>
    <td>$duration</td>
  </tr>
  <tr>
    <th>Clients</th>
    <td>{$round['info']['clients']}</td>
  </tr>
  <tr>
    <th>Builds completed</th>
    <td>{$round['info']['builds']}</td>
  </tr>
</table>

HEADER;
        $buildtypes = array();
        foreach($round['clients'] as $client => $builds) {
            foreach($builds as $build) {
                if (!isset($buildtypes[$build['type']]))
                    $buildtypes[$build['type']] = true;
//                if ($build['type'] == '')
//                    print_r($build);
            }
        }

        $typenames = array(
            'queued' => 'Queued build (and upload)',
            'dequeued' => 'Dequeued build',
            'completed' => 'Completed build (and upload)',
            'cancelled' => 'Cancelled build',
            'abandoned' => 'Abandoned build',

            'boot' => 'Bootloader build',
            'sim' => 'Simulator build',
            'target' => 'Normal build (and upload)',
            'wps' => 'WPS build',
        );
        print("<table>\n");
        foreach($typenames as $type => $desc) {
            if (!isset($buildtypes[$type])) continue;
            printf("<tr>\n    <td><div class='build %s' style='width: 3em'>",
                $type
            );
            if ($type == 'target' || $type == 'queued' || $type == 'completed') {
                print("<div class='build upload' style='width: 1em'></div>");
            }
            printf("</div></td>\n    <th>%s</th>\n  </tr>",
                $desc
            );
        }
        print("</table>\n");
    
        printf("<table>\n");
        foreach ($round['clients'] as $client => $builds) {
            printf("  <tr>\n    <th><a name='%s'>%s</a></th>\n    <td class='buildcell'>\n", $client, $client);
            
            $printline = false;
            $lineprinted = false;
            
            foreach ($builds as $build) {
                /*
                if ($printline && !$lineprinted && ($build['type'] != 'queued' && $build['type'] != 'dequeued')) {
                    $lineprinted = true;
                    print("      <hr />\n");
                }
                if ($build['type'] == 'queued' || $build['type'] == 'dequeued') {
                    $printline = true;
                }
                */

                $labelname = sprintf("labels/%s.gif", md5($build['id']));
                if (file_exists($labelname) && filemtime($labelname) > filemtime('label.php'))
                    $labelurl = $labelname;
                else
                    $labelurl = sprintf("label.php?s=%s", urlencode($build['id']));

                printf("      <div class='build %s' title='%s' style='width: %f%s; margin-left: %f%s; background-image: url(%s)'>",
                    $build['type'],
                    sprintf("%s - build time %d seconds%s", $build['id'], $build['end']-$build['start']-$build['ultime'], isset($build['builtby']) ? ' built by '.$build['builtby'] : ''),
                    max("0.2", $width * ($build['end'] - $build['start']) / $round['info']['duration']),
                    $unit,
                    $width * $build['start'] / $round['info']['duration'],
                    $unit,
                    $labelurl
                );
                if (isset($build['ultime']) && $build['ultime'] > 0) {
                    printf("\n        <div class='build upload' style='width: %f%s' title='upload time %d seconds'></div>\n      ",
                        $width * $build['ultime'] / $round['info']['duration'],
                        $unit,
                        $build['ultime']
                    );
                }
                print("</div>\n");
            }
            print("    </td>\n  </tr>\n");
        }
        printf("</table>\n");

?>
<hr />
<a href="http://www.rockbox.org">
  <img src="/rockbox/rockbox100.png" border="0" width="100" height="32" alt="www.rockbox.org" title="Rockbox - Open Source Jukebox Firmware" />
</a>
<small>Last updated <?php echo date('D M j H:i:s T Y', $round['info']['roundend']); ?></small>
<?php

    }

}

$g = new grapher();
$g->connect();

$revision = isset($_GET['r']) ? $_GET['r'] : 22286;
if (isset($_GET['debug'])) {
    $round = $g->get_debug_results($revision);
}
else {
    $round = $g->get_results($revision);
}
$g->gantt_chart($round);

?>
