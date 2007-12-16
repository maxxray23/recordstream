use Test::More qw(no_plan);
use OperationHelper;

BEGIN { use_ok( 'Recs::Operation::fromsplit' ) };

my $input;
my $output;

$input = <<INPUT;
A1 A2,2 A3
B1 B2 B3,B4 B5
INPUT
$output = <<OUTPUT;
{"f1":"A1","1":"A2,2","2":"A3"}
{"f1":"B1","1":"B2","2":"B3,B4","3":"B5"}
OUTPUT
test1(['-f', 'f1', '-d', ' '], $input, $output);
$output = <<OUTPUT;
{"0":"A1 A2","1":"2 A3"}
{"0":"B1 B2 B3","1":"B4 B5"}
OUTPUT
test1([], $input, $output);

sub test1
{
   my ($args, $input, $output) = @_;

   open(STDIN, "-|", "echo", "-n", $input) || ok(0, "Cannot open echo?!");
   my $fromsplit = Recs::Operation::fromsplit->new($args);
   OperationHelper->new("operation" => $fromsplit, "input" => undef, "output" => $output)->matches();
}
