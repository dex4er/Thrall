use strict;
use warnings;

use HTTP::Tiny;
use Plack::Runner;
use Test::More;
use Test::TCP;

if ($^O =~ /^(MSWin32|cygwin)$/) {
    plan skip_all => 'TCP tests on Windows';
    exit 0;
}

test_tcp(
    server => sub {
        my $port = shift;
        my $runner = Plack::Runner->new;
        $runner->parse_options(
            qw(--server Thrall --max-workers 0 --port), $port,
        );
        $runner->run(
            sub {
                my $env = shift;
                my $buf = '';
                        while (length($buf) != $env->{CONTENT_LENGTH}) {
                    my $rlen = $env->{'psgi.input'}->read(
                        $buf,
                        $env->{CONTENT_LENGTH} - length($buf),
                        length($buf),
                    );
                    last unless $rlen > 0;
                }
                return [
                    200,
                    [ 'Content-Type' => 'text/plain' ],
                    [ $buf ],
                ];
            },
        );
    },
    client => sub {
        my $port = shift;
        note 'send a broken request';
        my $sock = IO::Socket::INET->new(
            PeerAddr => "127.0.0.1:$port",
            Proto    => 'tcp',
        ) or die "failed to connect to server:$!";
        $sock->print(<< "EOT");
POST / HTTP/1.0\r
Content-Length: 6\r
\r
EOT
        undef $sock;
        note 'send next request';
        my $ua = HTTP::Tiny->new( timeout => 10 );
        my $res = $ua->post_form("http://127.0.0.1:$port/", { a => 1 });
        ok $res->{success};
        is $res->{status}, 200;
        is $res->{content}, 'a=1';
    },
);

done_testing;
