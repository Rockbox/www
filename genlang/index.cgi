#!/usr/bin/perl

# get three files into random file names
# svn cat -r[rrv] genlang
# svn cat -r[rrv] apps/langs/[lang].lang
# svn cat -r[rrv] apps/langs/english.lang

# run:
# genlang -t=[target]:[features] -e=english.lang -o [lang].lang 

# show the output to the user

require "CGI.pm";

my $rand = rand(1000000000).$$;

my $rev = CGI::param('rev');
my $target = CGI::param('t');
my $features = CGI::param('f');
my $lang = CGI::param('lang');

print "Content-Type: text/plain; charset=UTF8\n\n";

my $is_release = 0;
# if rev contains a dot it's a version number.
if($rev =~ m/(\d)\.(\d)/) {
    $is_release = 1;
}

# store hash before modifying $rev
my $hash = $rev;
$hash =~ s/[^\da-f]//g;

$rev =~ s/[^\d\.]//g;
$target =~ s/[^a-z0-9]//g;
$features =~ s/[^a-z0-9:_-]//g;
$lang =~ s/[^a-z-]//g;

my $temp="/tmp/rockbox-genlang";

#print "show rev $rev, target $target, features $features, lang $lang, rand $rand<br>\n";

if( ! -d $temp ) {
    # make sure the temp output dir exists!
    mkdir($temp);
}

# remove temp files older than 5 minutes
`find $temp -mmin +5 -type f | xargs rm -f`;

my $cmd1;
my $cmd2;

if($is_release == 1) {
    # get hash using git ls-remote
    $hash = `git ls-remote git://git.rockbox.org/rockbox.git refs/tags/v$rev-final`;
    $hash =~ s/\s+.*\n?//;
 }

$cmd1="curl -s 'https://git.rockbox.org/cgit/rockbox.git/plain/apps/lang/$lang.lang?id=$hash' > $temp/lang-$lang-$rand";
$cmd2="curl -s 'https://git.rockbox.org/cgit/rockbox.git/plain/apps/lang/english.lang?id=$hash' > $temp/english-$rand";

#print "$cmd1<br>\n";
#print "$cmd2<br>\n";

print `$cmd1`;
print `$cmd2`;

if(-s "$temp/lang-$lang-$rand" &&
    -s "$temp/english-$rand" ) {
    system("./updatelang $temp/english-$rand $temp/lang-$lang-$rand $temp/lang-$lang-patched-$rand");
    print `./genlang -t=$target:$features -e=$temp/english-$rand -o $temp/lang-$lang-patched-$rand`;
}
else {
    print "Empty output. Bad input?\n";
}
