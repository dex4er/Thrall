use inc::Module::Install;

all_from 'lib/Starlet.pm';
readme_from 'lib/Starlet.pm';

requires 'Plack' => 0.9920;

test_requires 'Test::More' => 0.88;
test_requires 'Test::TCP'  => 0.15;

WriteAll;
