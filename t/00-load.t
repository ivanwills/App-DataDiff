#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;

BEGIN {
    use_ok( 'App::DataDiff' );
}

diag( "Testing App::DataDiff $App::DataDiff::VERSION, Perl $], $^X" );
done_testing();
