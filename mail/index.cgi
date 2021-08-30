#!/usr/bin/perl

require "../date.pm";
require "../rockbox.pm";
require CGI;

$req = new CGI;

my $list = $req->param('list');

header("Rockbox mail", "mail");

sub showarchs {
    my ($prefix, $num, @dirs) = @_;

    my %years;
    my %mons;

    if($num > 0) {
        while(scalar(@dirs) > $num) {
            shift @dirs;
        }
    }

    for(@dirs) {
        if($_ =~ /(\d\d\d\d)-(\d\d)/) {
            $years{$1}=1;
            $mons{"$1-$2"}=1;
        }
    }

    @syears = sort keys %years;
    
    print "<table class=\"archive\">\n";

    for(reverse @syears) {
        my $thisyear=$_;

        print "<tr>\n";
        print "<th>$thisyear</th>\n";

        for (my $i = 1 ; $i <= 12 ; $i++) {
          my $mon = sprintf("%02d", $i);
          if (defined($mons{"$thisyear-$mon"})) {
              print "<td><a href=\"archive/rockbox${prefix}-archive-$thisyear-$mon\">".&MonthNameEng($mon)."</a></td>\n";
          } else {
	      print "<td></td>\n";
	  }
        }
        print "</tr>\n";
    }
    print "</tr></table>\n";

}

sub archive {
    my ($prefix, $num)=@_;

    my $some_dir="archive";
    opendir(DIR, $some_dir) || die "can't opendir $some_dir: $!";
    my @dirs = sort {$a cmp $b} grep { /^rockbox$prefix-archive-/ && -d "$some_dir/$_" } readdir(DIR);
    closedir DIR;

    &showarchs($prefix, $num, @dirs);
}


print <<END;
<p>
Our mailing lists have several hundred subscribers each and we want order and
<a href="etiquette.html">proper netiquette</a> to be followed for things to
run smooth. <b>Please</b> read this before you decide to post to any of our
lists.

</blockquote>
<hr>
<h2>rockbox</h2>
<blockquote>
<p>This is the big users and discussion list. It has many subscribers and quite
intense traffic at times.

<p> The list is only open for subscribers. You can not send mail to this list without being subscribed to it!

<p><a href="//lists.haxx.se/mailman/listinfo/rockbox">subscribe or unsubscribe to rockbox-users</a>

<p><b>Rockbox-users Archive</b>
END

archive("", -1);

print <<END;

<p>This list is also archived as a newgroup on Gmane. Connect your news reader to <a href="news://news.gmane.io">news.gmane.io</a> and look for the group <a href="news://news.gmane.io/gmane.comp.systems.archos.rockbox.general">gmane.comp.systems.archos.rockbox.general</a>. Note that you still need to be subscribed to the list to post to it through gmane!
END

print <<END;
</blockquote>
<hr>
<h2>rockbox-dev</h2>
<blockquote>
<p>This is the developers list. We talk source code, bugs, internal design,
commit reviews, porting issues and how to write efficient code.

<p>The list is only open for subscribers. You can not send mail to this list
without being subscribed to it!

<p><a href="//lists.haxx.se/mailman/listinfo/rockbox-dev">subscribe or unsubscribe to rockbox-dev</a>
<p><b>Rockbox-dev Archive</b>
END

archive("-dev", -1);

print <<END;

<p>This list is also archived as a newgroup on Gmane. Connect your news reader to <a href="news://news.gmane.io">news.gmane.io</a> and look for the group <a href="news://news.gmane.io/gmane.comp.systems.archos.rockbox.devel">gmane.comp.systems.archos.rockbox.devel</a>. Note that you still need to be subscribed to the list to post to it through Gmane!
END

</blockquote>
<hr>

<h2>rockbox-cvs</h2>
<blockquote>
<p>This list monitors the <a href="//git.rockbox.org">Git</a> commits and recieves one mail for each commit.  It is read-only and unarchived.

<p>To subscribe or unsubscribe: <a href="//lists.haxx.se/mailman/listinfo/rockbox-cvs">go here</a>

</blockquote>
<hr>

<h2>rockbox-sf</h2>
<blockquote>
<p>This list monitors the <a href="/tracker/">Flyspray</a> bug reports and feature requests and receives one mail for new and modified entries. It is read-only and unarchived.

<p>To subscribe or unsubscribe: <a href="//lists.haxx.se/mailman/listinfo/rockbox-sf">go here</a>

END

print "</blockquote><hr><h2>Bounce removal</h2>\n";

print "<p>If your email address bounces repeatedly, you will be removed from the lists without further notice.";

&footer();
