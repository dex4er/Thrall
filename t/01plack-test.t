#!/usr/bin/perl

use strict;
use warnings;

BEGIN { delete $ENV{http_proxy} };

use Test::More;
use Plack::Test::Suite;

if ($^O eq 'MSWin32' and $] >= 5.016 and ($] < 5.018002 or $] >= 5.019 and $] < 5.019005)) {
    plan skip_all => 'Perl with bug RT#119003 on Windows';
    exit 0;
}

push @Plack::Test::Suite::TEST,
    [
        'sleep',
        sub {
            sleep 1;
            pass;
        },
        sub {
            # nothing
        },
    ];

Plack::Test::Suite->run_server_tests('Thrall');
done_testing();

