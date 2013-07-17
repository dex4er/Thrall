use strict;
use Test::More;
use Plack::Test::Suite;

if ($^O =~ /^(MSWin32|cygwin)$/) {
    plan skip_all => 'TCP tests on Windows';
    exit 0;
}

Plack::Test::Suite->run_server_tests('Thrall');
done_testing();

