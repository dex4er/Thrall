#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::TCP;
use HTTP::Tiny;
use Plack::Loader;

if ($^O =~ /^(MSWin32|cygwin)$/) {
    plan skip_all => 'TCP tests on Windows';
    exit 0;
}

test_tcp(
    client => sub {
        my $port = shift;
        sleep 1;
        my $ua = HTTP::Tiny->new;
        my $res = $ua->get("http://localhost:$port/");
        ok( $res->{success} );
        like( scalar $res->{headers}{server}, qr/Thrall/ );
        unlike( scalar $res->{headers}{server}, qr/Hello/ );

        $res = $ua->get("http://localhost:$port/?server=1");
        ok( $res->{success} );
        unlike( scalar $res->{headers}{server}, qr/Thrall/ );
        like( scalar $res->{headers}{server}, qr/Hello/ );
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
            my @headers = ('Content-Type','text/html');
            push @headers, 'Server', 'Hello' if $env->{QUERY_STRING};
            [200, \@headers, ['HELLO']];
        });
        exit;
    },
);

done_testing;

