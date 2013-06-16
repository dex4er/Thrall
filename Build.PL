#!/usr/bin/perl

use 5.006;

use strict;
use warnings;

use threads;

use lib 'inc';
use Module::Build::My;

my $module = 'Thrall';

(my $dist = $module) =~ s/::/-/g;

my $build = Module::Build::My->new(
    module_name             => $module,
    license                 => 'perl',
    requires                => {
        'perl'                  => 5.008_001,
        'threads',              => 0,
        'Plack'                 => 0.9920,
    },
    build_requires          => {
        'HTTP::Tiny'            => 0,
        'Test::More'            => 0.88,
        'Test::TCP'             => 0.15,
    },
    script_files => [
        'script/thrall.pl',
    ],
    auto_configure_requires => 0,
    create_makefile_pl      => 'traditional',
    create_readme           => 1,
    create_license          => 1,
    recursive_test_files    => 0,
    add_to_cleanup          => [
        '*.bak', '*.gz', '*.tgz', '*.ppd', '*.ppmx', '*.deb',
        'pm_to_blib', 'cover_db', 'Debian_CPANTS.txt',
        'compilet*', 'test-*',
        "$dist-*",
    ],
    meta_merge              => {
        resources               => {
            bugtracker => "http://github.com/dex4er/$dist/issues",
            repository => "http://github.com/dex4er/$dist",
        },
    },
);

$build->create_build_script;
