use IO::Socket;

my $secret = $ARGV[0];
my $rev = $ARGV[1];
if (!$rev) {
    print "Bad rev $ARGV[0]\n";
    exit;
}

$sock = IO::Socket::INET->new(PeerAddr => "buildmaster.rockbox.org",
                              PeerPort => 19999,
                              Proto    => 'tcp');
if ($sock and $sock->connected) {
    print $sock "HELLO commander $secret\n";
    sleep 1;
    print $sock "BUILD $rev\n";
    sleep 1;
}
