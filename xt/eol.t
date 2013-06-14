#!/usr/bin/perl

use Test::More;
use Test::EOL;

open my $fh, 'MANIFEST' or die $!;
while (<$fh>) {
    chomp;
    s/\t.*//s;
    open my $fh2, $_ or next;
    my $line = <$fh2>;
    close $fh2;
    next unless /\.(c|cc|cpp|md|pl|pm|psgi|sh|t|txt)$/i or $line =~ m{^#!.*\bperl};
    eol_unix_ok $_, "No incorrect line endings in '$_'", { trailing_whitespace => 1, all_reasons => 1 };
};

done_testing();
