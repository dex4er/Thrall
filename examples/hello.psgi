#!/usr/bin/perl

use YAML::XS;

sub {
    my $dump = Dump @_;

    return [ 200, [ "Content-Type" => "text/plain", "Content-Length" => length($dump) ], [ $dump ] ];
};
