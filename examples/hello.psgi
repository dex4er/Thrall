#!/usr/bin/perl

# Simple PSGI application

use strict;
use warnings;

my $app = sub {
    [
        200, ['Content-Type' => 'text/html'],
        ['<!DOCTYPE html><html><head><title>Hello, world!</title></head><body>Hello, world!</body></html>']
    ]
};

use Plack::Builder;

builder {
    enable_if { $_[0]->{QUERY_STRING} =~ /foo/ } 'TrafficLog';

    # enable 'Debug';
    $app;
};
