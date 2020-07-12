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

my $use_svn = 0;
my $is_release = 0;
# if rev contains a dot it's a version number.
if($rev =~ m/(\d)\.(\d)/) {
    $is_release = 1;
}
# check if $rev is a svn revision number.
# if it's less than 6 digits, has only digits and the value is less than 31647
if($rev =~ m/^\d{1,5}$/) {
    $use_svn = 1;
}
# store hash before modifying $rev
my $hash = $rev;
$hash =~ s/[^\da-f]//g;

$rev =~ s/[^\d\.]//g;
$target =~ s/[^a-z0-9]//g;
$features =~ s/[^a-z0-9:_-]//g;
$lang =~ s/[^a-z-]//g;

my $temp="/tmp/rockbox-genlang";

# remove temp files older than 5 minutes
`find $temp -mmin +5 -type f | xargs rm -f`;

#print "show rev $rev, target $target, features $features, lang $lang, rand $rand<br>\n";

if( ! -d $temp ) {
    # make sure the temp output dir exists!
    mkdir($temp);
}

#`svn cat -r$rev tools/genlang >temp/genlang-$rand`;

my $cmd1;
my $cmd2;
if($use_svn == 1) {
    my $rev_opt = "-r$rev";
    my $svn_path = "svn://svn.rockbox.org/rockbox/trunk";

    if ($rev =~ /\./) {
        $rev =~ s/\./_/g;
        $svn_path = "svn://svn.rockbox.org/rockbox/tags/v$rev";
        $rev_opt = "";
    }
    elsif(($rev < 10000) || ($rev > 100000)) {
        print "Bad rev input\n";
        exit;
    }

    $cmd1="svn cat $rev_opt $svn_path/apps/lang/$lang.lang >$temp/lang-$lang-$rand";
    $cmd2="svn cat $rev_opt $svn_path/apps/lang/english.lang >$temp/english-$rand";
}
else {
    if($is_release == 1) {
        # get hash using git ls-remote
        $hash = `git ls-remote git://git.rockbox.org/rockbox.git refs/tags/v$rev-final`;
        $hash =~ s/\s+.*\n?//;
    }
    # not sure if constructing the blob has to download this way is valid.
    # Seems to work.
    my $curl_opt = "http://git.rockbox.org/?p=rockbox.git;hb=$hash;a=blob_plain;f=apps/lang/";
    $cmd1="curl -s '${curl_opt}$lang.lang' > $temp/lang-$lang-$rand";
    $cmd2="curl -s '${curl_opt}english.lang' > $temp/english-$rand";
}

print `$cmd1`;
print `$cmd2`;

if(-s "$temp/lang-$lang-$rand" &&
    -s "$temp/english-$rand" ) {
    print `./genlang -t=$target:$features -e=$temp/english-$rand -o $temp/lang-$lang-$rand`;
}
else {
    print "Empty output. Bad input?\n";
}
