#!/usr/bin/perl -w
#
# Working example of doing listen/accept of incoming connections,
# and non-blocking read of data on those connections.
# 05-Sep-2002 Ralph Siemsen <ralphs@netwinder.org>

#use strict;
use IO::Socket;
use IO::Select;

# Each active connection gets an entry here, keyed by its filedes.
# Could have used IO::Socket objects as keys, but they hash poorly.
# Any per-connection data can be sotred in this hash-of-hashes.
my %conn;

#
# {$rh}{'cmd'} for building incoming commands
#  {'client'} 
#  {'archs'} 
#  {'cpu'} - string for stats
#  {'bits'} 32 / 64 
#  {'os'}
#
my %client;

sub build {
    my ($build, $rh) = @_;
}

sub HELLO {
    my ($rh, $args) = @_;

    my ($version, $auth, $client, $archlist, $cpu, $bits,
        $os) = split(" ", $args);

    $client{$rh}{'client'} = $client;
    $client{$rh}{'archs'} = $archlist;
    $client{$rh}{'cpu'} = $cpu;
    $client{$rh}{'bits'} = $bits;
    $client{$rh}{'os'} = $os;

    # send OK
    $rh->write("_HELLO ok $client\n");
}


sub parsecmd {
    my ($rh, $cmdstr)=@_;
    
    if($cmdstr =~ /([A-Z]*) (.*)/) {
        my $func = $1;
        my $rest = $2;
        chomp $rest;
        print "$func received\n";

        &$func($rh, $rest);
    }
}

# Master socket for receiving new connections
my $server = new IO::Socket::INET(
	LocalHost => "localhost",
	LocalPort => 19999,
	Proto => "tcp",
	Listen => SOMAXCONN,
	Reuse => 1)
or die "socket: $!\n";

my $debug;

# Add the master socket to select mask
my $read_set = new IO::Select();
$read_set->add($server);
$conn{$server->fileno} = { type => 'master' };

# Mail loop active until ^C pressed
my $done = 0;
$SIG{INT} = sub { warn "received interrupt\n"; $done = 1; };
while(not $done) {
	my @handles = sort map $_->fileno, $read_set->handles;
	warn "waiting on (@handles)\n" if($debug);
	my ($rh_set, $timeleft) =
            IO::Select->select($read_set, undef, undef, 1);

	foreach my $rh (@$rh_set) {
		die "untracked rh" unless exists $conn{$rh->fileno};
		my $type = $conn{$rh->fileno}{type};
		warn "event $rh, fd ", $rh->fileno, ", type $type\n";
		if ($type eq 'master') {
			warn "server accepting\n";
			my $new = $rh->accept or die;
			$read_set->add($new);
			$conn{$new->fileno} = { type => 'http' };
			$new->blocking(0) or die "blocking: $!";
		} else {
			warn "client trying to read\n";
			my $data;
			my $len = $rh->read($data, 512);

			# Note: thereis a bug here.  Since the socket is
			# nonblocking we should read all available data.
			# Otherwise we won't be woken up again.
			if ($data) {
                            warn "okay, read '$data'\n";
                            $client{$rh}{'cmd'} .= $data;
                            my $c = $client{$rh}{'cmd'};
                            
                            my $pos = index($c, "\n");
                            if($pos != -1) {
                                print "GOT: $c\n";
                                parsecmd($rh, $c);
                                $client{$rh}{'cmd'} = substr($c, $pos);
                            }
			}
                        else {
                            warn "failed, removing client\n";
                            delete $conn{$rh->fileno};
                            $read_set->remove($rh);
                            $rh->close;
			}
		}
	}
        #print "ping\n";
}
warn "exiting.\n";
