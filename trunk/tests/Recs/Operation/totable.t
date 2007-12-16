use Test::More qw(no_plan);
use OperationHelper;

BEGIN { use_ok( 'Recs::Operation::totable' ) };

my $stream = <<STREAM;
{"foo":1,"zoo":"biz1"}
{"foo":2,"zoo":"biz2"}
{"foo":3,"zoo":"biz3"}
{"foo":4,"zoo":"biz4"}
{"foo":5,"zoo":"biz5"}
STREAM

my $solution = <<SOLUTION;
foo   zoo 
---   ----
1     biz1
2     biz2
3     biz3
4     biz4
5     biz5
SOLUTION

OperationHelper->test_output(
   'totable',
   [],
   $stream,
   $solution,
);

my $solution2 = <<SOLUTION;
1   biz1
2   biz2
3   biz3
4   biz4
5   biz5
SOLUTION

OperationHelper->test_output(
   'totable',
   [qw(--no-header)],
   $stream,
   $solution2,
);

my $solution3 = <<SOLUTION;
foo
---
1  
2  
3  
4  
5  
SOLUTION

OperationHelper->test_output(
   'totable',
   [qw(--f foo)],
   $stream,
   $solution3,
);

