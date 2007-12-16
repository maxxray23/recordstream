use Test::More qw(no_plan);

BEGIN { use_ok( 'Recs::Operation::grep' ) };

my $stream = <<STREAM;
{"foo":1,"zoo":"biz1"}
{"foo":2,"zoo":"biz2"}
{"foo":3,"zoo":"biz3"}
{"foo":4,"zoo":"biz4"}
{"foo":5,"zoo":"biz5"}
STREAM

my $solution = <<SOLUTION;
{"foo":3,"zoo":"biz3"}
{"foo":4,"zoo":"biz4"}
{"foo":5,"zoo":"biz5"}
SOLUTION

my $dir = $ENV{'BASE_TEST_DIR'};

use OperationHelper;

my $grep = Recs::Operation::grep->new([ '$r->{foo} > 2' ]);

my $helper = OperationHelper->new(
   operation => $grep,
   input     => $stream,
   output    => $solution,
);

$helper->matches();
