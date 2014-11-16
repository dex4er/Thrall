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
use File::ShareDir;
use HTTP::Request;
use Test::More;
use Digest::MD5;

if ($^O eq 'MSWin32' and $] >= 5.016 and $] < 5.019005 and not $ENV{PERL_TEST_BROKEN}) {
    plan skip_all => 'Perl with bug RT#119003 on MSWin32';
    exit 0;
}

$Plack::Test::Impl = "Server";
$ENV{PLACK_SERVER} = 'Thrall';
$ENV{PLACK_QUIET} = 1;

my $file = File::ShareDir::dist_dir('Plack') . "/baybridge.jpg";

my $app = sub {
    my $env = shift;
    my $body;
    my $clen = $env->{CONTENT_LENGTH};
    while ($clen > 0) {
        $env->{'psgi.input'}->read(my $buf, $clen) or last;
        $clen -= length $buf;
        $body .= $buf;
    }
    return [ 200, [ 'Content-Type', 'text/plain', 'X-Content-Length', $env->{CONTENT_LENGTH} ], [ $body ] ];
};

test_psgi $app, sub {
    my $cb = shift;
    sleep 1;

    open my $fh, "<:raw", $file;
    local $/ = \1024;

    my $req = HTTP::Request->new(POST => "http://localhost/");
    $req->content(sub { scalar <$fh> });

    my $res = $cb->($req);

    is $res->header('X-Content-Length'), 79838;
    is Digest::MD5::md5_hex($res->content), '983726ae0e4ce5081bef5fb2b7216950';

    sleep 1;
};

done_testing;
