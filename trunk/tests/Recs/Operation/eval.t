use Test::More qw(no_plan);
use OperationHelper;

BEGIN { use_ok( 'Recs::Operation::eval' ) };

my $stream = <<STREAM;
{"foo":1,"zoo":"biz1"}
{"foo":2,"zoo":"biz2"}
{"foo":3,"zoo":"biz3"}
{"foo":4,"zoo":"biz4"}
{"foo":5,"zoo":"biz5"}
STREAM

my $solution = [ '1 biz1',
                 '2 biz2',
                 '3 biz3',
                 '4 biz4',
                 '5 biz5', ];

my $op = Recs::Operation::eval->new([ '$r->{foo} . " " . $r->{zoo}']);

ok($op, "Object initialization");

my @output;
$op->set_printer(sub { push @output, shift() });

my $helper = OperationHelper->new(
      operation => $op,
      input     => $stream,
      output    => '',
);

$helper->matches();

use Data::Dumper;
print Dumper \@output;

is_deeply(\@output, $solution, "Output matches excepted");
