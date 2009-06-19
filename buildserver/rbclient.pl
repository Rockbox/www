#!/usr/bin/perl

#use strict;
use IO::Socket;
use IO::Select;

my $clientver = 1;
my $username = "foobar";
my $password = "master";
my $clientname = "laptop-".$$;
my $archlist = "m68k,arm.sh";

my $proto = getprotobyname('tcp');
socket(SOCKET, PF_INET, SOCK_STREAM, $proto) or die;

my $port = 19999;

my $sock = IO::Socket::INET->new(PeerAddr => 'localhost',
                                 PeerPort => 19999,
                                 Proto    => 'tcp',
                                 Blocking => 0)
    or die "$!";

my $auth = "$username:$password";
my $speed = &bogomips;
my $cpu = `uname -m`;
chomp $cpu;
my $os = `uname -o`;
chomp $os;

# Add the master socket to select mask
my $read_set = new IO::Select();
$read_set->add($sock);

print $sock "HELLO $clientver $archlist $auth $clientname $cpu 32 $os $speed\n";

# Mail loop active until ^C pressed
my $done = 0;
$SIG{INT} = sub { warn "received interrupt\n"; $done = 1; };

while (not $done) {
    my @handles = sort map $_->fileno, $read_set->handles;
    my ($rh_set, $timeleft) =
        IO::Select->select($read_set, undef, undef, 1);

    foreach my $rh (@$rh_set) {
        my $data;
        my $len = $rh->read($data, 512);
        
        if ($len) {
            $input .= $data;
            
            my $pos = index($input, "\n");
            if($pos != -1) {
                parsecmd($input);
                $input = substr($input, $pos);
            }
        }
    }

    for my $id (sort {$a <=> $b} keys %builds) {
        print "Starting build $builds{$id}{confargs}\n";
    }
}

#################################################

sub bogomips
{
    open CPUINFO, "</proc/cpuinfo" or return 0;
    my @lines = grep 'bogomips:', <CPUINFO>;
    close CPUINFO;

    my $bogomips = 0;
    for (@lines) {
        if (/bogomips\s*: (\d+)/) {
            $bogomips += $1;
        }
    }

    return $bogomips;
}
    
sub _HELLO
{
}

sub BUILD
{
    my ($id, $confargs, $rev, $zip, $mt) = split(' ', shift @_);

    if (defined $builds{$id}) {
        print SOCKET "_BUILD 0\n";
        return;
    }

    $builds{$id}{confargs} = $confargs;
    $builds{$id}{rev} = $rev;
    $builds{$id}{zip} = $zip;
    $builds{$id}{mt} = $mt;

    print SOCKET "_BUILD $id\n";
}

sub parsecmd
{
    my ($cmdstr)=@_;
    
    if($cmdstr =~ /([_A-Z]*) (.*)/) {
        my $func = $1;
        my $rest = $2;
        chomp $rest;
        print "client: $func received\n";

        &$func($rest);
    }
    else {
        print "Client didn't recognize '$cmdstr'\n";
    }
}
