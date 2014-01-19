#!/usr/bin/perl

=head1 NAME

thrall - a simple PSGI/Plack HTTP server which uses threads

=head1 SYNOPSIS

$ thrall --workers=20 --max-reqs-per-child=100 app.psgi

$ thrall --port=80 --ipv6=1 app.psgi

$ thrall --port=443 --ssl=1 --ssl-key-file=file.key --ssl-cert-file=file.crt app.psgi

$ thrall --socket=/tmp/thrall.sock app.psgi

=head1 DESCRIPTION

Thrall is a standalone HTTP/1.1 server with keep-alive support. It uses
threads instead pre-forking, so it works correctly on Windows. It is pure-Perl
implementation which doesn't require any XS package.

=head1 OPTIONS

See L<plackup> and L<Thrall> for available command line options.

=cut


use 5.008_001;

use strict;
use warnings;

our $VERSION = '0.0202';

use Plack::Runner;

sub version {
    print "Thrall $VERSION\n";
}

my $runner = Plack::Runner->new(
    server     => 'Thrall',
    env        => 'deployment',
    loader     => 'Delayed',
    version_cb => \&version,
);
$runner->parse_options(@ARGV);
$runner->run;


=head1 SEE ALSO

L<http://github.com/dex4er/Thrall>.

=head1 AUTHOR

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2013-2014 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See L<http://dev.perl.org/licenses/artistic.html>
