package Recs::Operation::grep;

use base qw(Recs::Operation Recs::ExpressionHolder);

sub init {
   my $this = shift;
   my $args = shift;

   $this->parse_options($args);
   $this->_set_expr(shift @{$this->_get_extra_args()});
}

sub accept_record {
   my $this   = shift;
   my $record = shift;

   $DB::single=1;

   eval {
      if ( $this->run_expr($record) ) {
         $this->push_record($record);
      }
   };

   if ( $@ ) {
      warn "Code threw: $@";
   }
}

sub usage {
   return <<USAGE;
Usage: recs-grep <args> <expr> [<files>]
   <expr> is evaluated as perl on each record of input (or records from
   <files>) with \$r set to a Recs::Record object and \$line set to the current
   line number (starting at 1).  Records for which the evaluation is a perl
   true are printed back out.

Arguments:
   --help   Bail and output this help screen.

Examples:
   Filter to records with field 'name' equal to 'John'
      recs-grep '\$r->{name} eq "John"'
USAGE
}

1;
