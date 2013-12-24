#!/usr/bin/perl

use strict;
use warnings;

use Plack::Loader;
use Test::More;
use Test::TCP qw(empty_port);

if ($^O eq 'MSWin32' and $] >= 5.016 and ($] < 5.018002 or $] >= 5.019 and $] < 5.019005)) {
    plan skip_all => 'Perl with bug RT#119003 on Windows';
    exit 0;
}

my $thrall = Plack::Loader->load(
    'Thrall',
    min_reqs_per_child => 5,
    max_reqs_per_child => 10,
);

sleep 1;

my ($min, $max) = (7, 7);
for (my $i = 0; $i < 10000; $i++) {
    my $n = $thrall->_calc_reqs_per_child();
    $min = $n
        if $n < $min;
    $max = $n
        if $n > $max;
}

is $min, 5, "min";
is $max, 10, "max";

done_testing;
