# secrets.pm is optional and may contain:
#
# The master commander password that must be presented when connecting
# $rb_cmdpasswd = "secret";
#
# Enabling the commander concept
# $rb_cmdenabled = 1;       enables the commander system
#
# The shell script run after each build is completed. The arguments for this
# script is $buildid $client-$user.
# NOTE: this script is called synchronously. Make it run fast.
# $rb_eachcomplete = "scriptname.sh";
#
# The shell script run after each build round is completed. No arguments.
# NOTE: this script is called synchronously. Make it run fast.
# $rb_buildround = "scriptname.sh"
#
# The account details used to access the mysql database.
# $rb_dbuser = 'dbuser';
# $rb_dbpwd = 'dbpwd';
#
use DBI;
eval 'require "secrets.pm"';

sub getbuilds {
    my $filename="builds";

    %builds = ();
    @buildids = ();

    system("svn up -q --non-interactive $filename");

    open(F, "<$filename");
    while(<F>) {
        # sdl:nozip:recordersim:Recorder - Simulator:rockboxui:--target=recorder,--ram=2,--type=s
        if($_ =~ /([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):(\d+)/) {
            my ($arch, $zip, $id, $name, $file, $confopts, $score) =
                ($1, $2, $3, $4, $5, $6, $7);
            $builds{$id}{'arch'}=$arch;
            $builds{$id}{'zip'}=$zip;
            $builds{$id}{'name'}=$name;
            $builds{$id}{'file'}=$file;
            $builds{$id}{'confopts'}=$confopts;
            $builds{$id}{'score'}=$score;
            $builds{$id}{'handcount'} = 0; # not handed out to anyone
            $builds{$id}{'assigned'} = 0; # not assigned to anyone
            $builds{$id}{'done'} = 0; # not done
            $builds{$id}{'uploading'} = 0; # not uploading

            push @buildids, $id;
        }
    }
    close(F);

    my @s = sort {$builds{$b}{score} <=> $builds{$a}{score}} keys %builds;
    $topscore = int($builds{$s[0]}{score} / 2);
}


sub getspeed
{
    return 0 unless ($db);

    my $avgsize = 5;
    my ($cli) = @_;
    my $maxrows = 25;

    my $rows = $getspeed_sth->execute($cli, $maxrows);
    if ($rows > 0) {
        #print "$rows rows\n";
        my ($points, $time);

        # fetch score for $avgcount latest revisions (build rounds)
        while (my ($id, $tottime, $ultime) = $getspeed_sth->fetchrow_array()) {
            $points += $builds{$id}{score};
            $time += ($tottime - $ultime);
        }
        return int($points / $time);
    }
    return 0;
}

sub db_connect
{
    my $dbpath = 'DBI:mysql:rockbox';
    $db = DBI->connect($dbpath, $rb_dbuser, $rb_dbpwd) or
        warn "DBI: Can't connect to database: ". DBI->errstr;

    # prepare some statements for later execution:

    $submit_update_sth = $db->prepare("UPDATE builds SET client=?,timeused=?,ultime=?,ulsize=? WHERE revision=? and id=?") or
        warn "DBI: Can't prepare statement: ". $db->errstr;

    $submit_new_sth = $db->prepare("INSERT INTO builds (revision,id) VALUES (?,?) ON DUPLICATE KEY UPDATE client='',timeused=0,ultime=0,ulsize=0") or
        warn "DBI: Can't prepare statement: ". $db->errstr;

    $setlastrev_sth = $db->prepare("INSERT INTO clients (name, lastrev) VALUES (?,?) ON DUPLICATE KEY UPDATE lastrev=?") or
        warn "DBI: Can't prepare statement: ". $db->errstr;

    $getspeed_sth = $db->prepare("SELECT id, timeused, ultime FROM builds WHERE client=? ORDER BY revision DESC LIMIT ?") or
        warn "DBI: Can't prepare statement: ". $db->errstr;
}

sub nicehead {
    my ($title)=@_;

    open(READ, "<head.html");
    while(<READ>) {
        s/_PAGE_/$title/;
        print $_;
    }
    close(READ);

}

sub nicefoot {
    open(READ, "<foot.html");
    while(<READ>) {
        print $_;
    }
    close(READ);
}

1;
