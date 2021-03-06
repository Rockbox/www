#!/usr/bin/perl
require "./rbmaster.pm";

my $rev = $ARGV[0];
my $build = $ARGV[1];

db_connect();

my $sth = $db->prepare("UPDATE builds SET errors=?,warnings=? WHERE revision=? and id=?") or
    warn "DBI: Can't prepare statement: ". $db->errstr;

my $status;
my $warnings = 0;
my $errors = 0;

if (open(LOG, "<data/$rev-$build.log")) {
    for my $line (<LOG>) {
        if ($line =~ /^Build Status: (.*)/) {
            $status = $1;
        }
        else {
            if ($line =~ /^([^:]*):(\d*):.*warning: (.*)/)
            {
                if($3 !~ /\(near/)
                {
                    # we don't count "(near" comments as warnings
                    $warnings+=1;
                    #print "Warning: $line";
                }
            }
            elsif (($line =~ /^([^:]*):(\d*):.*note: (.*)/) ||
                   ($line =~ /^In file included/))
            {
                # some gcc versions like to print notes every now and then
                # we'll ignore those
            }
            elsif (($line =~ /^([^:]+):(\d+):(.+)/) ||
                   ($line =~ /: undefined reference to/) ||
                   ($line =~ /gcc: .*: No such file or/) ||
                   ($line =~ /ld returned (\d+) exit status/) ||
                   ($line =~ /^git: /) ||
                   ($line =~ /^Build Failure: /) ||
#                   ($line =~ /^error:/i) ||
                   ($line =~ /^ *make: *\*\*\*/) )
            {
                # error
                $errors+=1;
                #print "Error: $line";
            }
        }
    }
}
else {
    die "Failed opening 'data/$rev-$build.log'\n";
}

if (!$errors and $status ne "Fine") {
    $errors = 1;
}

$sth->execute($errors, $warnings, $rev, $build);
