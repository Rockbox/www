#!/usr/bin/perl

use CGI 'param';

print "Content-type: text/html\n\n";

my $hash = param('rchash');
my $pwd = param('rcpw');

if (!$hash) {
    print("<html><body><h2>Start a release-candidate build</h2>\n",
          "<form action='rcbuild.cgi' autocomplete='off'>\n",
          "RC Hash <input name='rchash' type='text' size='10'><br>\n",
          "RC Pwd <input name='rcpw' type='password' size='10'><br>\n",
          "<input value='Build' type='submit'><br>\n",
          "</form></body></html>\n"
          );
    exit;
}

if ($hash =~ /[^\da-fA-F]/ or length($hash) != 7) {
    print"Invalid hash.\n";
    exit;
}

$output = `(cd /home/rockbox/rockbox_git_clone && git show --oneline $hash)`;
unless ($output =~ /^$hash/) {
    print "Nonexisting hash.";
    exit;
}

my $secret = `cat /home/rockbox/rcbuild.passwd`;
chomp $secret;
if ($pwd ne $secret) {
    print "Wrong password.\n";
    exit;
}

if (-f "data/build_running") {
    print "A build is running. You can only start an RC build when the server is idle.";
    exit;
}

if (-f "rcbuild.hash") {
    my $h = `cat rcbuild.hash`;
    print "An RC build is already running for hash $h. Patience, grasshopper.";
    exit;
}

$secret = `cat /home/rockbox/rbmaster.passwd`;
chomp $secret;

`echo $hash > rcbuild.hash`;
`perl startbuild.pl $secret $hash`;

print "$hash build started.";
