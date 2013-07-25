# NAME

Thrall - a simple PSGI/Plack HTTP server which uses threads

# SYNOPSIS

    $ plackup -s Thrall --port=80 [options] your-app.psgi

# DESCRIPTION

Thrall is a standalone HTTP/1.0 server with keep-alive support. It uses
threads instead pre-forking, so it works correctly on Windows.

# COMMAND LINE OPTIONS

In addition to the options supported by [plackup](http://metacpan.org/module/plackup), Thrall accepts following
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

# NOTES

Thrall was started as a fork of [Starlet](http://metacpan.org/module/Starlet) server. It has almost the same code
as [Starlet](http://metacpan.org/module/Starlet) and it was adapted to use threads instead fork().

# SEE ALSO

[Starlet](http://metacpan.org/module/Starlet),
[Starman](http://metacpan.org/module/Starman)

# LIMITATIONS

There is a problem with Perl implementation on Windows XP/Vista/7. Some
requests can fail with message:

    failed to set socket to nonblocking mode:An operation was attempted on
    something that is not a socket.

Perl on Windows 8 works correctly. Also Cygwin version seems to be correct.

See [https://rt.perl.org/rt3/Public/Bug/Display.html?id=119003](https://rt.perl.org/rt3/Public/Bug/Display.html?id=119003) for more
informations about this issue.

See ["BUGS AND LIMITATIONS" in threads](http://metacpan.org/module/threads#BUGS-AND-LIMITATIONS) and ["Thread-Safety of System Libraries" in perlthrtut](http://metacpan.org/module/perlthrtut#Thread-Safety-of-System-Libraries) to read about limitations for PSGI applications started
with Thrall and check if you encountered a known problem.

Especially, PSGI applications should avoid: changing current working
directory, catching signals, staring new processes. Environment variables
might (Linux, Unix) or might not (Windows) be shared between threads.

# BUGS

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
