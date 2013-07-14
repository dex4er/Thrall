# NAME

Thrall - a simple PSGI/Plack HTTP server which uses threads

# SYNOPSIS

    $ plackup -s Thrall --port=80 [options] your-app.psgi

# DESCRIPTION

Thrall is a standalone HTTP/1.0 server with keep-alive support. It uses
threads instead pre-forking, so it works correctly on Windows.

# COMMAND LINE OPTIONS

In addition to the options supported by [plackup](http://search.cpan.org/perldoc?plackup), Thrall accepts following
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

# NOTES

Thrall was started as a fork of [Starlet](http://search.cpan.org/perldoc?Starlet) server. It has almost the same code
as [Starlet](http://search.cpan.org/perldoc?Starlet) and it was adapted to use threads instead fork().

# SEE ALSO

[Starlet](http://search.cpan.org/perldoc?Starlet),
[Starman](http://search.cpan.org/perldoc?Starman)

# BUGS

There is a problem with Perl implementation on Windows XP/Vista/7. Some
requests can fail with message:

    failed to set socket to nonblocking mode:An operation was attempted on
    something that is not a socket.

Perl on Windows 8 works correctly.

If you find the bug or want to implement new features, please report it at
[https://github.com/dex4er/Thrall/issues](https://github.com/dex4er/Thrall/issues)

The code repository is available at
[http://github.com/dex4er/Thrall](http://github.com/dex4er/Thrall)

# AUTHOR

Kazuho Oku

miyagawa

Piotr Roszatycki <dexter@cpan.org>

# LICENSE

Copyright (c) 2013 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See [http://dev.perl.org/licenses/artistic.html](http://dev.perl.org/licenses/artistic.html)
