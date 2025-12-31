#!/usr/bin/perl

use strict;
use warnings;

#use POE qw(Component::IRC);
use POE qw(Component::IRC::State);

use POE::Component::IRC::Plugin::AutoJoin;
use POE::Component::IRC::Plugin::Connector;
use POE::Component::IRC::Plugin::NickServID;
use POE::Component::IRC::Plugin::Logger;
use POE::Component::Client::TCP;

use JSON::Parse 'parse_json';
use HTTP::Tiny;
use HTML::Parser;

my $buildmaster = 'buildmaster.rockbox.org';
my $port = 19999;
my $client_rev = 999;

my $nickname = "rb-chanbot";
my $ircname = "Rockbox Channel Bot";
my $server = "irc.libera.chat";
my $logchan = "#rockbox";
my $buildcreds = "logger chanbot:password rockbox";
my $ircpass = $ENV{'IRCPASS'};

# for debugging
#$nickname = "rb-chanbotdev";
#$buildcreds = "loggerdev chanboddev:password rockbox";
#$logchan = "#rockbox-community";

my %channels = (  "$logchan" => '' );

my $irc = POE::Component::IRC::State->spawn(
#my $irc = POE::Component::IRC->spawn(
    nick => $nickname,
    ircname => $ircname,
    server => $server,
    ) or die "Fail to launch $!";

sub _start {
    my $heap = $_[HEAP];
    my $irc = $heap->{irc};

    # Connector plugin
    $heap->{connector} = POE::Component::IRC::Plugin::Connector->new();
    $irc->plugin_add( 'Connector' => $heap->{connector} );
    # Autojoin plugin
    $irc->plugin_add('AutoJoin', POE::Component::IRC::Plugin::AutoJoin->new(
			 Channels => \%channels
		     ));
    # Identify with nickserv
    $irc->plugin_add( 'NickServID', POE::Component::IRC::Plugin::NickServID->new(
	Password => $ircpass,
    ));
    # Logging
    $irc->plugin_add('Logger', POE::Component::IRC::Plugin::Logger->new(
	Path    => '/home/rockbox/irc-logs',  # .../#channel/YYY-MM-DD.log
	DCC     => 1,
	Private => 0,
	Notices => 1,
	Public  => 1,
	Sort_by_date => 1,
	Restricted => 0,
	#Format => { ... },  ## customize
    ));

    $irc->yield( register => 'all');
    $irc->yield( connect => { } );
    return;
}

sub irc_001 {
    my $sender = $_[SENDER];
    my $irc = $sender->get_heap();

    print "Connected to ", $irc->server_name(), "\n";

    # join our channels
    $irc->yield( join => $_) for keys(%channels);
    return;
}

my $fstitle = "";
my $url = "";

sub get_gitrev {
    my ($id) = @_;
    $url = "https://git.rockbox.org/cgit/rockbox.git/commit/?id=$id";

    my $http = HTTP::Tiny->new->get($url);
    if ($http->{success}) {
	my $p = HTML::Parser->new(api_version => 3);
	$p->handler(start => sub {
	    my ($tagname, $attr, $self) = @_;
	    return unless $tagname eq "div";
	    if (defined($attr->{class}) && $attr->{class} eq "commit-subject") {
		$self->handler(text => sub {
		    return if $fstitle;
		    $fstitle = shift;
#		    print "found '$fstitle'\n";
			       }, "dtext");
		$self->handler(end => "eof", "self" );
	    }
		    }, "tagname,attr,self");
	$p->parse($http->{content});
    }
}

sub irc_public {
    my ($sender, $who, $where, $what) = @_[SENDER, ARG0 .. ARG2];
    my $nick = ( split /!/, $who )[0];
    my $channel = $where->[0];
    my $irc = $sender->get_heap();

    if ($what =~ /(^|\s)g#?(\d+)/i ) {
	my $id = $2;
	my $queryurl = "https://gerrit.rockbox.org/r/changes/$id/detail";
	my $http = HTTP::Tiny->new->get($queryurl);
	if ($http->{success}) {
	    my $trimmed = substr($http->{content}, 4);
	    my $obj = parse_json($trimmed);

	    my $title = $$obj{'subject'};
	    my $project = $$obj{'project'};
	    my $author = $$obj{'owner'}{'name'};
	    my $url = "https://gerrit.rockbox.org/r/c/$project/+/$id";

	    my $msg = "Gerrit review #$id at $url : \x0311$title by $author";
	    $irc->yield( privmsg => $channel => $msg );
	}
    } elsif ($what =~ /(^|\s)FS#?(\d+)/i ) {
	my $id = $2;
	$url = "https://www.rockbox.org/tracker/task/$id";

	my $http = HTTP::Tiny->new->get($url);
	if ($http->{success}) {
	    my $p = HTML::Parser->new(api_version => 3);
	    $p->handler(start => sub {
		return if shift ne "title";
		my $self = shift;
		$self->handler(text => sub { $fstitle = shift; }, "dtext");
		$self->handler(
		    end => sub {
			shift->eof if shift eq "title";
		    },
		    "tagname,self"
		    );
			}, "tagname,self");
	    $p->parse($http->{content});
	    if ($fstitle) {
		$fstitle =~ s/FS#\d+ : (.*)/$1/;
		my $msg = "$url : \x0311$fstitle";
		$fstitle = "";
		$irc->yield( privmsg => $channel => $msg );
	    }
	}
    } elsif ($what =~ /(^|\s)r#?([A-F0-9]+)/i ) {
	my $id = $2;
	get_gitrev($id);
	if ($fstitle) {
	    my $msg = "$url : \x0311$fstitle";
	    $fstitle = "";
	    $irc->yield( privmsg => $channel => $msg );
	}
    }
    # TODO:  log everything?  ie replace dancer etc?

    return;
}

sub _default {
    my ($event, $args) = @_[ARG0 .. $#_];
    my @output = ( "$event: " );

    for my $arg (@$args) {
	if ( ref $arg eq 'ARRAY' ) {
	    push( @output, '[' . join(', ', @$arg ) . ']' );
	} else {
	    push ( @output, "'$arg'" );
	}
    }
#    print join ' ', @output, "\n";
    return;
}

POE::Session->create(
    package_states => [
	main => [ qw(_default _start irc_001 irc_public) ],
	],
	heap => { irc => $irc },
    );

####

POE::Component::Client::TCP->new(
    RemoteAddress => 'buildmaster.rockbox.org',
    RemotePort => 19999,
    Connected => sub {
	my $heap = $_[HEAP];
	$heap->{server}->put("HELLO $client_rev $buildcreds abacus 10 perl");
    },
    ServerInput => sub {
	my $channel = $logchan;
	my $heap = $_[HEAP];
	my $input = $_[ARG0];
	if($input =~ /^([_A-Z]*) *(.*)/) {
	    my $func = $1;
	    my $rest = $2;
	    chomp($rest);

#	    print "Server:  $func / $rest\n";

	    if ($func eq "_HELLO") {
		print "Connected to $buildmaster\n";

		if ($rest ne "ok") {
		    # XXX HACF?
		}
	    } elsif ($func eq "PING") {
		$heap->{server}->put("_PING $rest");
	    } elsif ($func eq "MESSAGE") {
		if ($rest =~ /New build round started. Revision (\w+),/) {
		    $rest = "\x033$rest";
		    $irc->yield( privmsg => $channel => $rest );
		    get_gitrev($1);
		    if ($fstitle) {
			my $msg = "$1 : \x0311$fstitle";
			$fstitle = "";
			$irc->yield( privmsg => $channel => $msg );
		    }
		} elsif ($rest =~ /Build round completed/) {
		    $rest = "\x033$rest";
		    $irc->yield( privmsg => $channel => $rest );
		} elsif ($rest =~ /Revision (\w+) result: All green/) {
		    $rest = "\x033$rest";
		    $irc->yield( privmsg => $channel => $rest );
		} elsif ($rest =~ /Revision (\w+) result: (\d+) errors(.*)/) {
		    if ($2 == 0) {
			$rest = "\x038$rest";
		    } else {
			$rest = "\x034$rest";
		    }
		    $irc->yield( privmsg => $channel => $rest );
		}

		# "New build round started. Revision $rev, $num_builds builds, $num_clients clients."
		# "Build round completed after $took seconds."
		# "Revision $buildround result: $errors errors $warnings warnings"
		# "Revision $buildround result: All green"
	    }
	}
    },
    Disconnected => sub {
	$_[KERNEL]->delay( reconnect => 15 );
    },
    ) or die "Fail to launch $!";

###

POE::Kernel->run();
