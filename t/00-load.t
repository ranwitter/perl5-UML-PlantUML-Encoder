#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
  use_ok('Lingua::PlantUML::Encode') || print "Bail out!\n";
}

diag(
"Testing Lingua::PlantUML::Encode $Lingua::PlantUML::Encode::VERSION, Perl $], $^X"
);
