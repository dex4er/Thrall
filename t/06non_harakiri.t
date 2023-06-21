#!/usr/bin/perl

use strict;
use warnings;

BEGIN { delete $ENV{http_proxy} }

use LWP::UserAgent;
use Plack::Runner;
use Test::TCP;
use Test::More;

if ($^O eq 'MSWin32' and $] >= 5.016 and $] < 5.019005 and not $ENV{PERL_TEST_BROKEN}) {
    plan skip_all => 'Perl with bug RT#119003 on MSWin32';
    exit 0;
}

if ($^O eq 'cygwin' and not eval { require Win32::Process; }) {
    plan skip_all => 'Win32::Process required';
    exit 0;
}

test_tcp(
    client => sub {
        my $port = shift;
        sleep 1;
        my %seen_pid;

        my $ua = LWP::UserAgent->new;
        for (1 .. 23) {
            $ua->timeout(10);
            my $res = $ua->get("http://127.0.0.1:$port/");
            ok $res->is_success, 'is_success';
            is $res->code, '200', 'code';
            is $res->message, 'OK', 'message';
            like $res->content, qr/^\d+$/, 'content';
            $seen_pid{ $res->content }++;
        }

        cmp_ok(keys(%seen_pid), '<=', 10, 'In non-harakiri mode, pid is reused');

        sleep 1;
    },
    server => sub {
        my $port = shift;
        my $runner = Plack::Runner->new;
        $runner->parse_options(
            qw(--server Thrall --env test --quiet --max-workers 10 --ipv6=0 --host 127.0.0.1 --port), $port,
        );
        $runner->run(
            sub { [200, ['Content-Type' => 'text/plain'], [threads->tid]] },
        );
    }
);

done_testing;
