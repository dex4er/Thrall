#!/usr/bin/perl

use strict;
use warnings;

use Carp ();

$SIG{__WARN__} = sub { local $Carp::CarpLevel = 1; Carp::confess("Warning: ", @_) };

use Test::More tests => 2;

BEGIN { use_ok 'Thrall::Server' };
BEGIN { use_ok 'Plack::Handler::Thrall' };
