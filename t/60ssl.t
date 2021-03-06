#!/usr/bin/perl

use strict;
use warnings;

BEGIN { delete $ENV{http_proxy} }

# workaround for HTTP::Tiny + Test::TCP
BEGIN { $INC{'threads.pm'} = 0 };
sub threads::tid { }
use HTTP::Tiny;
use Test::TCP;
BEGIN { delete $INC{'threads.pm'} }
BEGIN { $SIG{__WARN__} = sub { warn @_ if not $_[0] =~ /^Subroutine tid redefined/ } }

use Test::More;
use FindBin;

use Thrall::Server;

if ($^O eq 'MSWin32' and $] >= 5.016 and $] < 5.019005 and not $ENV{PERL_TEST_BROKEN}) {
    plan skip_all => 'Perl with bug RT#119003 on MSWin32';
    exit 0;
}

if ($^O eq 'cygwin' and not $ENV{PERL_TEST_BROKEN}) {
    plan skip_all => 'Broken on cygwin';
    exit 0;
}

if (not eval { require IO::Socket::SSL; }) {
    plan skip_all => 'IO::Socket::SSL required';
    exit 0;
}

if (not eval { require Net::SSLeay; Net::SSLeay->VERSION(1.49); }) {
    plan skip_all => 'Net::SSLeay >= 1.49 required';
    exit 0;
}

if (eval { require Acme::Override::INET; } ) {
    plan skip_all => 'Acme::Override::INET is not supported';
    exit 0;
}

my $ca_crt     = "$FindBin::Bin/../examples/ca.crt";
my $client_crt = "$FindBin::Bin/../examples/client.crt";
my $client_key = "$FindBin::Bin/../examples/client.key";
my $server_crt = "$FindBin::Bin/../examples/localhost.crt";
my $server_key = "$FindBin::Bin/../examples/localhost.key";

test_tcp(
    client => sub {
        my $port = shift;
        sleep 1;
        my $ua = HTTP::Tiny->new(
            verify_SSL => 1,
            SSL_options => {
                SSL_ca_file   => $ca_crt,
                SSL_cert_file => $client_crt,
                SSL_key_file  => $client_key,
           }
        );
        my $res = $ua->get("https://127.0.0.1:$port/");
        ok $res->{success};
        like $res->{headers}{server}, qr/Thrall/;
        is $res->{content}, 'https';
        sleep 1;
    },
    server => sub {
        my $port = shift;
        Thrall::Server->new(
            quiet         => 1,
            host          => '127.0.0.1',
            port          => $port,
            ssl           => 1,
            ssl_key_file  => $server_key,
            ssl_cert_file => $server_crt,
            ssl_ca_file   => $ca_crt,
            ssl_client_ca_file => $ca_crt,
            ssl_verify_mode => 1,
        )->run(
            sub { [ 200, [], [$_[0]->{'psgi.url_scheme'}] ] },
        );
    }
);

done_testing;
