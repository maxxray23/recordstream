use strict;
use warnings;

use Test::More 'no_plan';
use Data::Dumper;
use Recs::Record;

BEGIN { use_ok("Recs::Aggregator::Minimum"); }

ok(my $aggr = Recs::Aggregator::Minimum->new("x"), "Initialize");

my $cookie = $aggr->initial();

foreach my $n (1, 3, 7)
{
   $cookie = $aggr->combine($cookie, Recs::Record->new("x" => $n));
}

my $value = $aggr->squish($cookie);

is($value, 1, "min of 1, 3, 7");
