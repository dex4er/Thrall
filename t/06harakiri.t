use strict;
use warnings;

use HTTP::Request::Common;
use Plack::Test;
use Test::More;

if ($^O =~ /^(MSWin32|cygwin)$/) {
    plan skip_all => 'TCP tests on Windows';
    exit 0;
}

$Plack::Test::Impl = 'Server';
$ENV{PLACK_SERVER} = 'Thrall';

test_psgi
    app => sub {
        my $env = shift;
        return [ 200, [ 'Content-Type' => 'text/plain' ], [threads->tid] ];
    },
    client => sub {
        my %seen_pid;
        my $cb = shift;
        sleep 1;
        for (1..23) {
            my $res = $cb->(GET "/");
            $seen_pid{$res->content}++;
        }
        cmp_ok(keys(%seen_pid), '<=', 10, 'In non-harakiri mode, pid is reused')
    };

test_psgi
    app => sub {
        my $env = shift;
        $env->{'psgix.harakiri.commit'} = $env->{'psgix.harakiri'};
        return [ 200, [ 'Content-Type' => 'text/plain' ], [threads->tid] ];
    },
    client => sub {
        my %seen_pid;
        my $cb = shift;
        sleep 1;
        for (1..23) {
            my $res = $cb->(GET "/");
            $seen_pid{$res->content}++;
        }
        is keys(%seen_pid), 23, 'In Harakiri mode, each pid only used once';
    };

done_testing;
