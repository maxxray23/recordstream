package OperationHelper;

use Test::More;
use Recs::InputStream;

sub new {
   my $class = shift;
   my %args  = @_;

   my $this = {
      INPUT     => create_stream($args{'input'}),
      OUTPUT    => create_stream($args{'output'}),
      OPERATION => $args{'operation'},
   };

   bless $this, $class;

   return $this;
}

sub create_stream {
   my $input = shift;

   return undef unless ( $input );

   if ( UNIVERSAL::isa($input, 'Recs::InputStream') ) {
      return $input;
   }

   if ( (not ($input =~ m/\n/m))  && -e $input ) {
      return Recs::InputStream->new(FILE => $input);
   }

   return Recs::InputStream->new(STRING => $input);
}

sub matches {
   my $this = shift;

   my $op     = $this->{'OPERATION'};
   my $input  = $this->{'INPUT'};
   my $keeper = Keeper->new();

   $op->set_input_stream($input);
   $op->_set_next_operation($keeper);
   $op->run_operation();
   $op->finish();

   my $output  = $this->{'OUTPUT'};
   my $results = $keeper->get_records();
   my $i = 0;

   if ( $output ) {
      while ( my $rec = $output->get_record() ) {
         is_deeply($results->[$i], $rec, "Records match");
         $i++;
      }
   }

   ok((not $results->[$i]), "no extra records");
}

sub do_match {
   my $class          = shift;
   my $operation_name = shift;
   my $args           = shift;
   my $input          = shift;
   my $output         = shift;

   my $operation_class = "Recs::Operation::$operation_name";
   my $op = $operation_class->new($args);

   my $helper = $class->new(
      operation => $op,
      input     => $input,
      output    => $output,
   );

   $helper->matches();

   return $helper;
}


package Keeper;

use base qw(Recs::Operation);

sub new {
   my $class = shift;
   my $this = { RECORDS => [] };
   bless $this, $class;
   return $this;
}

sub accept_record {
   my $this = shift;
   my $record = shift;
   push @{$this->{'RECORDS'}}, $record;
}

sub get_records {
   my $this = shift;
   return $this->{'RECORDS'};
}

1;
