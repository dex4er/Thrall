#!/usr/bin/perl

use strict;
use warnings;

BEGIN { delete $ENV{http_proxy} };

use Test::More;
use Test::TCP;
use IO::Socket::INET;
use Plack::Loader;

if ($^O eq 'MSWin32' and $] >= 5.016 and ($] < 5.018002 or $] >= 5.019 and $] < 5.019005)) {
    plan skip_all => 'Perl with bug RT#119003 on Windows';
    exit 0;
}

test_tcp(
    client => sub {
        my $port = shift;
        sleep 1;
        my $sock = IO::Socket::INET->new(
            PeerAddr => "localhost:$port",
            Proto => 'tcp',
        );
        ok($sock);
        my $localport = $sock->sockport;
        my $req = "GET / HTTP/1.0\015\012\015\012";
        $sock->syswrite($req,length($req));
        $sock->sysread( my $buf, 1024);
        like( $buf, qr/HELLO $localport/);
        sleep 1;
    },
    server => sub {
        my $port = shift;
        my $loader = Plack::Loader->load(
            'Thrall',
            port => $port,
            max_workers => 5,
        );
        $loader->run(sub{
            my $env = shift;
            my @headers = ();
            my $remote_port = $env->{REMOTE_PORT};
            [200, ['Content-Type'=>'text/html'], ['HELLO '.$remote_port]];
        });
        exit;
    },
);

done_testing;

