use Test::More qw(no_plan);

BEGIN { use_ok( 'Recs::Operation' ) };

my $op = Recs::Operation->new();

ok($op, "Constructor worked");

my ($foo);
my $args_spec = {
   'foo=s' => \$foo,
};

$op->parse_options($args_spec, [ '--foo', 'bar' ]);

ok($foo eq 'bar', "Option parsing test");
