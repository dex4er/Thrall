package Thrall;

=head1 NAME

Thrall - a simple PSGI/Plack HTTP server which uses threads

=head1 SYNOPSIS

  % plackup -s Thrall --port=80 [options] your-app.psgi

=head1 DESCRIPTION

Thrall is a standalone HTTP/1.0 server with keep-alive support. It uses
threads instead pre-forking, so it works correctly on Windows.

=for readme stop

=cut


use 5.008_001;

use strict;
use warnings;

our $VERSION = '0.01';

1;


__END__

=head1 COMMAND LINE OPTIONS

In addition to the options supported by L<plackup>, Thrall accepts following
options(s).

=over

=item --max-workers=#

number of worker processes (default: 10)

=item --timeout=#

seconds until timeout (default: 300)

=item --keepalive-timeout=#

timeout for persistent connections (default: 2)

=item --max-keepalive-reqs=#

max. number of requests allowed per single persistent connection.  If set to
one, persistent connections are disabled (default: 1)

=item --max-reqs-per-child=#

max. number of requests to be handled before a worker process exits (default:
100)

=item --min-reqs-per-child=#

if set, randomizes the number of requests handled by a single worker process
between the value and that supplied by C<--max-reqs-per-chlid> (default: none)

=item --spawn-interval=#

if set, worker processes will not be spawned more than once than every given
seconds.  Also, when SIGHUP is being received, no more than one worker
processes will be collected every given seconds.  This feature is useful for
doing a "slow-restart". (default: none)

=item --main-thread-delay=#

the Thrall does not use signals or semaphores and it requires a small delay in
main thread so it doesn't consume all CPU. (default: 0.1)

=back

=for readme continue

=head1 NOTES

Thrall was started as a fork of L<Starlet> server. It has almost the same code
as L<Starlet> and it was adapted to use threads instead fork().

=head1 SEE ALSO

L<Starlet>,
L<Starman>

=head1 BUGS

If you find the bug or want to implement new features, please report it at
L<https://github.com/dex4er/Thrall/issues>

The code repository is available at
L<http://github.com/dex4er/Thrall>

=head1 AUTHOR

Kazuho Oku

miyagawa

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2013 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See L<http://dev.perl.org/licenses/artistic.html>
