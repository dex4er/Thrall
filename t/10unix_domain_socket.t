#!/usr/bin/perl

use strict;
use Test::More;
use Plack::Loader;
use File::Temp;
use IO::Socket::UNIX;
use Socket;

if ($^O =~ /^(MSWin32|cygwin)$/) {
    plan skip_all => 'Unix socket tests on Windows';
    exit 0;
}

my ($fh, $filename) = File::Temp::tempfile(UNLINK=>1);
unlink($filename);

my $pid = fork;
if ( $pid == 0 ) {
    # server
    my $loader = Plack::Loader->load(
        'Thrall',
        max_workers => 5,
        socket => $filename,
    );
    $loader->run(sub{
        my $env = shift;
        my $remote = $env->{REMOTE_ADDR} || 'UNIX';
        [200, ['Content-Type'=>'text/html'], ["HELLO $remote"]];
    });
    exit;
}

sleep 1;

my $client = IO::Socket::UNIX->new(
    Peer  => $filename,
    timeout => 3,
) or die "failed to listen to socket $filename:$!";

$client->syswrite("GET / HTTP/1.0\015\012\015\012");
$client->sysread(my $buf, 1024);
like $buf, qr/Thrall/;
like $buf, qr/HELLO UNIX/;

done_testing();

kill 'TERM',$pid;
waitpid($pid,0);
unlink($filename);

