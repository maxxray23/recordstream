package Recs::Operation;

use strict;
use warnings;

use Recs::InputStream;
use Getopt::Long;
use Carp;

sub new {
   my $class = shift;
   my $args  = shift;

   my $this = {
   };

   bless $this, $class;

   $this->init($args);
   return $this;
}

sub parse_options {
   my $this         = shift;
   my $args         = shift;
   my $options_spec = shift || {};

   $options_spec->{'help'} = sub { $this->print_usage(); exit 1; };

   local @ARGV = @$args;
   GetOptions(%$options_spec);

   $this->_set_extra_args(\@ARGV);
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

sub _set_extra_args {
   my $this = shift;
   my $args = shift;

   $this->{'EXTRA_ARGS'} = $args;
}

sub _get_extra_args {
   my $this = shift;
   return $this->{'EXTRA_ARGS'};
}

sub print_usage {
   my $this    = shift;
   my $message = shift;

   if ( $message ) {
      print "$message\n";
   }

   print $this->usage() . "\n";
}

sub init {
}

sub run_operation {
   my $this = shift;

   my $input = Recs::InputStream->new_magic($this->_get_extra_args());

   while ( my $record = $input->get_record() ) {
      $this->accept_record();
   }
}

sub accept_record {
   subclass_should_implement(shift);
}

sub subclass_should_implement {
   my $this = shift;
   croak "Subclass should implement: " . ref($this);
}

sub usage {
   subclass_should_implement(shift);
}

sub stream_done {
}

sub run_expr {
}

1;
