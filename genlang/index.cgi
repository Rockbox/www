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

$rev = 0 + $rev;
$target =~ s/[^a-z0-9]//g;
$features =~ s/[^a-z0-9:_-]//g;
$lang =~ s/[^a-z-]//g;

if(($rev < 10000) || ($rev > 100000)) {
    print "Bad rev input\n";
    exit;
}

my $temp="/tmp/rockbox-genlang";

# remove temp files older than 5 minutes
`find $temp -mmin +5 -type f | xargs rm -f`;

#print "show rev $rev, target $target, features $features, lang $lang, rand $rand<br>\n";

if( ! -d $temp ) {
    # make sure the temp output dir exists!
    mkdir($temp);
}

my $cd="cd /home/dast/src/rockbox &&";
#`svn cat -r$rev tools/genlang >temp/genlang-$rand`;
my $cmd="$cd svn cat -r$rev apps/lang/$lang.lang >$temp/lang-$lang-$rand";
#print "$cmd<br>";
print `$cmd`;
$cmd="$cd svn cat -r$rev apps/lang/english.lang >$temp/english-$rand";
print `$cmd`;

if(-s "$temp/lang-$lang-$rand" &&
   -s "$temp/english-$rand" ) {
    print `./genlang -t=$target:$features -e=$temp/english-$rand -o $temp/lang-$lang-$rand`;
}
else {
    print "Empty output. Bad input?\n";
}
