use inc::Module::Install;

all_from 'lib/Thrall.pm';
readme_from 'lib/Thrall.pm';

requires 'Plack' => 0.9920;

test_requires 'Test::More' => 0.88;
test_requires 'Test::TCP'  => 0.15;

WriteAll;
