package Recs::Operation::grep;

use base qw(Recs::Operation);

sub init {
   my $this = shift;
   my $args = shift;

   $this->parse_options($args);

   $this->_set_expr($this->_get_extra_args()->[0]);
}

sub _set_expr {
   my $this = shift;
   my $expr = shift;

   $this->{'expr'} = $expr;
}

sub _get_expr {
   my $this = shift;
   return $this->{'expr'};
}

sub accept_record {
   print "Got record\n";
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
