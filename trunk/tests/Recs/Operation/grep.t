use Test::More qw(no_plan);

BEGIN { use_ok( 'Recs::Operation::grep' ) };

my $stream = <<STREAM;

STREAM

use Recs::InputStream;

my $grep = Recs::Operation::grep->new();

my $input = Recs::InputStream->new(STRING => 
