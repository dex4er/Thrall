use strict;
use warnings;
use Test::More;
use Test::TCP;
use IO::Socket::INET;
use Plack::Loader;

if ($^O =~ /^(MSWin32|cygwin)$/) {
    plan skip_all => 'TCP tests on Windows';
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
    },
);

done_testing;

