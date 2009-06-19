#!/usr/bin/perl

use Socket;
use IO::Handle;

my $clientver = 1;
my $username = "foobar";
my $password = "master";
my $clientname = "laptop-".$$;
my $archlist = "m68k,arm.sh";

my $proto = getprotobyname('tcp');
socket(SOCKET, PF_INET, SOCK_STREAM, $proto) or die;

my $port = 19999;

my $sin = sockaddr_in($port, inet_aton("localhost"));
connect(SOCKET, $sin) || die;

SOCKET->autoflush(1);

sub hello {
    my $auth = "$username:$password";
    print SOCKET "HELLO $clientver $auth $clientname $archlist\n";
}

hello();

while(<SOCKET>) {
    print $_;
}
