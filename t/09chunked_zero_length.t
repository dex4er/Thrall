#!/usr/bin/perl

use strict;
use warnings;

BEGIN { delete $ENV{http_proxy} };

use Test::TCP;
use Plack::Test;
use HTTP::Request;
use Test::More;

if ($^O eq 'MSWin32' and $] >= 5.016 and ($] < 5.018002 or $] >= 5.019 and $] < 5.019005)) {
    plan skip_all => 'Perl with bug RT#119003 on Windows';
    exit 0;
}

$Plack::Test::Impl = "Server";
$ENV{PLACK_SERVER} = 'Thrall';

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
