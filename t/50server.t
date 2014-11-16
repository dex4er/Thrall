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

use Thrall::Server;

if ($^O eq 'MSWin32' and $] >= 5.016 and $] < 5.019005 and not $ENV{PERL_TEST_BROKEN}) {
    plan skip_all => 'Perl with bug RT#119003 on MSWin32';
    exit 0;
}

if ($^O eq 'cygwin' and not $ENV{PERL_TEST_BROKEN}) {
    plan skip_all => 'Broken on cygwin';
    exit 0;
}

test_tcp(
    client => sub {
        my $port = shift;
        sleep 1;
        my $ua = HTTP::Tiny->new;
        my $res = $ua->get("http://localhost:$port/");
        ok $res->{success};
        like $res->{headers}{server}, qr/Thrall/;
        like $res->{content}, qr/Hello/;
        sleep 1;
    },
    server => sub {
        my $port = shift;
        Thrall::Server->new(
            quiet    => 1,
            host     => 'localhost',
            port     => $port,
        )->run(
            sub { [ 200, [], ["Hello world\n"] ] },
        );
    }
);

done_testing;
