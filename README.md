[![Build Status](https://travis-ci.org/dex4er/Thrall.png?branch=master)](https://travis-ci.org/dex4er/Thrall)

# NAME

Thrall - a simple PSGI/Plack HTTP server which uses threads

# SYNOPSIS

    $ plackup -s Thrall --port=80 [options] your-app.psgi

    $ plackup -s Thrall --port=443 --ssl=1 --ssl-key-file=file.key --ssl-cert-file=file.crt [options] your-app.psgi

    $ plackup -s Thrall --port=80 --ipv6 [options] your-app.psgi

    $ plackup -s Thrall --socket=/tmp/thrall.sock [options] your-app.psgi

# DESCRIPTION

Thrall is a standalone HTTP/1.1 server with keep-alive support. It uses
threads instead pre-forking, so it works correctly on Windows. It is pure-Perl
implementation which doesn't require any XS package.

# COMMAND LINE OPTIONS

In addition to the options supported by [plackup](https://metacpan.org/pod/plackup), Thrall accepts following
options(s).

- \--max-workers=\#

    number of worker processes (default: 10)

- \--timeout=\#

    seconds until timeout (default: 300)

- \--keepalive-timeout=\#

    timeout for persistent connections (default: 2)

- \--max-keepalive-reqs=\#

    max. number of requests allowed per single persistent connection.  If set to
    one, persistent connections are disabled (default: 1)

- \--max-reqs-per-child=\#

    max. number of requests to be handled before a worker process exits (default:
    1000)

- \--min-reqs-per-child=\#

    if set, randomizes the number of requests handled by a single worker process
    between the value and that supplied by `--max-reqs-per-chlid` (default: none)

- \--spawn-interval=\#

    if set, worker processes will not be spawned more than once than every given
    seconds.  Also, when SIGHUP is being received, no more than one worker
    processes will be collected every given seconds.  This feature is useful for
    doing a "slow-restart". (default: none)

- \--main-thread-delay=\#

    the Thrall does not use signals or semaphores and it requires a small delay in
    main thread so it doesn't consume all CPU. (default: 0.1)

- \--thread-stack-size=\#

    sets a new default per-thread stack size. (default: none)

- \--ssl=\#

    enables SSL support. The [IO::Socket::SSL](https://metacpan.org/pod/IO::Socket::SSL) module is required. (default: 0)

- \--ssl-key-file=\#

    specifies the path to SSL key file. (default: none)

- \--ssl-cert-file=\#

    specifies the path to SSL certificate file. (default: none)

- \--ipv6=\#

    enables IPv6 support. The [IO::Socket::IP](https://metacpan.org/pod/IO::Socket::IP) module is required. (default: 0)

- \--socket=\#

    enables UNIX socket support. The [IO::Socket::UNIX](https://metacpan.org/pod/IO::Socket::UNIX) module is required. The
    socket file have to be not yet created. The first character `@` or `\0` in
    the socket file name means that abstract socket address will be created.
    (default: none)

# NOTES

Thrall was started as a fork of [Starlet](https://metacpan.org/pod/Starlet) server. It has almost the same code
as [Starlet](https://metacpan.org/pod/Starlet) and it was adapted to use threads instead fork().

# SEE ALSO

[Starlet](https://metacpan.org/pod/Starlet),
[Starman](https://metacpan.org/pod/Starman)

# LIMITATIONS

See ["BUGS AND LIMITATIONS" in threads](https://metacpan.org/pod/threads#BUGS-AND-LIMITATIONS) and ["Thread-Safety of System Libraries" in perlthrtut](https://metacpan.org/pod/perlthrtut#Thread-Safety-of-System-Libraries) to read about limitations for PSGI applications started
with Thrall and check if you encountered a known problem.

Especially, PSGI applications should avoid: changing current working
directory, catching signals, starting new processes. Environment variables
might (Linux, Unix) or might not (Windows) be shared between threads.

# BUGS

There is a problem with Perl threads implementation which occurs on Windows.
Some requests can fail with message:

    failed to set socket to nonblocking mode:An operation was attempted on
    something that is not a socket.

Cygwin version seems to be correct.

This problem was introduced in Perl 5.16 and fixed in Perl 5.18.2 and Perl
5.19.5.

See [https://rt.perl.org/rt3/Public/Bug/Display.html?id=119003](https://rt.perl.org/rt3/Public/Bug/Display.html?id=119003) for more
information about this issue.

## Reporting

If you find the bug or want to implement new features, please report it at
[https://github.com/dex4er/Thrall/issues](https://github.com/dex4er/Thrall/issues)

The code repository is available at
[http://github.com/dex4er/Thrall](http://github.com/dex4er/Thrall)

# AUTHORS

Piotr Roszatycki <dexter@cpan.org>

Based on Starlet by:

Kazuho Oku

miyagawa

kazeburo

Some code based on Plack:

Tatsuhiko Miyagawa

# LICENSE

Copyright (c) 2013 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See [http://dev.perl.org/licenses/artistic.html](http://dev.perl.org/licenses/artistic.html)
