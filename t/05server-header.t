#!/usr/bin/perl

use strict;
use warnings;

BEGIN { delete $ENV{http_proxy} }

# workaround for HTTP::Tiny + Test::TCP
BEGIN { $INC{'threads.pm'} = 0 }
sub threads::tid { }
use HTTP::Tiny;
use Test::TCP;
BEGIN { delete $INC{'threads.pm'} }
BEGIN { $SIG{__WARN__} = sub { warn @_ if not $_[0] =~ /^Subroutine tid redefined/ } }

use Test::More;
use Plack::Loader;

if ($^O eq 'MSWin32' and $] >= 5.016 and $] < 5.019005 and not $ENV{PERL_TEST_BROKEN}) {
    plan skip_all => 'Perl with bug RT#119003 on MSWin32';
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
            quiet => 1,
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
