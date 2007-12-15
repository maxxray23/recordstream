use strict;
use warnings;

use Test::More 'no_plan';
use Data::Dumper;
use Recs::Record;

BEGIN { use_ok("Recs::Aggregator::Maximum"); }

ok(my $aggr = Recs::Aggregator::Maximum->new("x"), "Initialize");

my $cookie = $aggr->initial();

foreach my $n (1, 3, 7)
{
   $cookie = $aggr->combine($cookie, Recs::Record->new("x" => $n));
}

my $value = $aggr->squish($cookie);

is($value, 7, "max of 1, 3, 7");
