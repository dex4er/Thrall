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

use Plack::Test;
use HTTP::Request;
use Test::More;

if ($^O eq 'MSWin32' and $] >= 5.016 and $] < 5.019005 and not $ENV{PERL_TEST_BROKEN}) {
    plan skip_all => 'Perl with bug RT#119003 on MSWin32';
    exit 0;
}

$Plack::Test::Impl = "Server";
$ENV{PLACK_SERVER} = 'Thrall';
$ENV{PLACK_QUIET} = 1;

my $app = sub {
    my $env = shift;
    return sub {
        my $response = shift;
        my $writer = $response->([ 200, [ 'Content-Type', 'text/plain' ]]);
        $writer->write("Content");
        $writer->write("");
        $writer->write("Again");
        $writer->close;
    }
};

test_psgi $app, sub {
    my $cb = shift;

    sleep 1;

    my $req = HTTP::Request->new(GET => "http://localhost/");
    my $res = $cb->($req);

    is $res->content, "ContentAgain";

    sleep 1;
};

done_testing;
