#!/usr/bin/perl

use strict;
use warnings;

use POE qw(Component::IRC);
use POE::Component::IRC::Plugin::AutoJoin;
use POE::Component::IRC::Plugin::Connector;

use JSON::Parse 'parse_json';
use HTTP::Tiny;
use HTML::Parser;

use IO::Socket;

my $nickname = "rb-chanbot";
my $ircname = "Rockbox Channel Bot";
my $server = "irc.libera.chat";
my @channels = ("#rockbox");
#my @channels = ("#rockbox-community");
my $buildmaster = 'buildmaster.rockbox.org';
my $port = 19999;

my $sock;

my $irc = POE::Component::IRC->spawn(
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
			 Channels => @channels
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
    $irc->yield( join => $_) for @channels;
    return;
}

my $fstitle = "";

sub irc_public {
    my ($sender, $who, $where, $what) = @_[SENDER, ARG0 .. ARG2];
    my $nick = ( split /!/, $who )[0];
    my $channel = $where->[0];

    if ($what =~ /g#?(\d+)/i ) {
	my $id = $1;
	my $queryurl = "https://gerrit.rockbox.org/r/changes/$id/detail";
	my $http = HTTP::Tiny->new->get($queryurl);
	if ($http->{success}) {
	    my $trimmed = substr($http->{content}, 4);
	    my $obj = parse_json($trimmed);

	    my $title = $$obj{'subject'};
	    my $project = $$obj{'project'};
	    my $author = $$obj{'owner'}{'name'};
	    my $url = "https://gerrit.rockbox.org/r/c/$project/+/$id";

	    my $msg = "Gerrit review #$id at $url : $title by $author";
	    $irc->yield( privmsg => $channel => $msg );
	}
    } elsif ($what =~ /FS#?(\d+)/i ) {
	my $id = $1;
	my $url = "https://www.rockbox.org/tracker/task/$id";

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
		my $msg = "$url : $fstitle";
		$fstitle = "";
		$irc->yield( privmsg => $channel => $msg );
	    }
	}
    } elsif ($what =~ /r#?([A-F0-9]+)/i ) {
	my $id = $1;
	my $url = "https://git.rockbox.org/cgit/rockbox.git/commit/?id=$id";

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
			print "found '$fstitle'\n";

				   }, "dtext");
		    $self->handler(end => "eof", "self" );
		}
		}, "tagname,attr,self");
	    $p->parse($http->{content});
	    if ($fstitle) {
		my $msg = "$url : $fstitle";
		$irc->yield( privmsg => $channel => $msg );
	    }
	    $fstitle = "";
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
    print join ' ', @output, "\n";
    return;
}

####

POE::Session->create(
    package_states => [
	main => [ qw(_default _start irc_001 irc_public) ],
	],
	heap => { irc => $irc },
    );

#while(1) {
#    $sock = IO::Socket::INET->new(PeerAddr => $buildmaster,
#				  PeerPort => $port,
#				  Proto    => 'tcp')
#	or sleep 1;
#    last if ($sock and $sock->connected);
#}
#$sock->blocking(0);
#
#print $sock "HELLO $revision logger rblogbot:password rb-logbot abacus 10 perl\n";

$poe_kernel->run();
