package Recs::Operation::join;

use strict;

use base qw(Recs::Operation);

use Recs::Executor;
use Recs::InputStream;
use Recs::OutputStream;
use Recs::Record;

sub init {
   my $this = shift;
   my $args = shift;

   my $left             = 0;
   my $right            = 0;
   my $inner            = 0;
   my $outer            = 0;
   my $operation        = "";
   my $accumulate_right = 0;

   my $spec = {
      "help"             => \&usage,
      "left"             => \$left,
      "right"            => \$right,
      "inner"            => \$inner,
      "outer"            => \$outer,
      "operation=s"      => \$operation,
      "accumulate-right" => \$accumulate_right,
   };

   $this->parse_options($args, $spec);

   if ( ! @{$this->_get_extra_args()} ) {
      die("You must provide inputkey");
   }

   my $inputkey = shift @{$this->_get_extra_args()};

   die("You must provide dbkey") unless (@{$this->_get_extra_args()});

   my $dbkey = shift @{$this->_get_extra_args()};

   usage("You must provide dbfile") unless (@{$this->_get_extra_args()});

   my $dbfile = shift @{$this->_get_extra_args()};

   $this->{'ACCUMULATE_RIGHT'} = $accumulate_right;
   $this->{'DB_KEY'}           = $dbkey;
   $this->{'INPUT_KEY'}        = $inputkey;
   $this->{'KEEP_LEFT'}        = $left || $outer;
   $this->{'KEEP_RIGHT'}       = $right || $outer;


   if ( $operation ) {
      $this->{'OPERATION'} = Recs::Executor->new($operation);
   }

   $this->create_db($dbfile, $dbkey);

   $this->{'KEYS_PRINTED'} = {};
}

sub create_db {
   my $this = shift;
   my $file = shift;
   my $key  = shift;

   my $db_stream = Recs::InputStream->new('FILE' => $file);
   my %db;
   my $record;

   while($record = $db_stream->get_record()) {
      my $value = $this->value_for_key($record, $key);

      $db{$value} = [] unless ( $db{$value} );
      push @{$db{$value}}, $record;
   }

   $this->{'DB'} = \%db;
}

sub value_for_key {
   my $this   = shift;
   my $record = shift;
   my $key    = shift;

   return ${$record->guess_key_from_spec($key, 0)};
}

sub accept_record {
   my $this   = shift;
   my $record = shift;

   my $value = $this->value_for_key($record, $this->{'INPUT_KEY'});

   my $db = $this->{'DB'};

   if(my $db_records = $db->{$value}) {
      foreach my $db_record (@$db_records) {
         if ($this->{'ACCUMULATE_RIGHT'}) {
            if ($this->{'OPERATION'}) {
               $this->run_expression($db_record, $record);
            }
            else {
               foreach my $this_key (keys %$record) {
                  if (!exists($db_record->{$this_key})) {
                     $db_record->{$this_key} = $record->{$this_key};
                  }
               }
            }
         }
         else {
            if ($this->{'OPERATION'}) {
               my $output_record = Recs::Record->new(%$db_record);
               $this->run_expression($output_record, $record);
               $this->push_record($output_record);
            }
            else {
               $this->push_record(Recs::Record->new(%$record, %$db_record));
            }

            if ($this->{'KEEP_LEFT'}) {
               $this->{'KEYS_PRINTED'}->{$value} = 1;
            }
         }
      }
   }
   elsif ($this->{'KEEP_RIGHT'}) {
      $this->push_record($record);
   }
}

# TODO: shove down into executor
sub run_expression {
   my $__MY__this = shift;
   my $d    = shift;
   my $i    = shift;

   no strict;
   no warnings;
   eval $__MY__this->{'OPERATION'}->{'CODE'};
}

sub stream_done {
   my $this = shift;
   if ($this->{'KEEP_LEFT'}) {
      foreach my $db_records (values %{$this->{'DB'}}) {
         foreach my $db_record (@$db_records) {
            my $value = $this->value_for_key($db_record, $this->{'DB_KEY'});
            if (!exists($this->{'KEYS_PRINTED'}->{$value})) {
               $this->push_record($db_record);
            }
         }
      }
   }
}

sub usage {
   return <<USAGE;
Usage: recs-join <args> <inputkey> <dbkey> <dbfile> [<files>]
   Records of input (or records from <files>) are joined against records in
   <dbfile>, using field <inputkey> from input and field <dbkey> from <dbfile>.
   Each record from input may match 0, 1, or more records from <dbfile>. Each
   pair of matches will be combined to form a larger record, with fields from
   the dbfile overwriting fields from the input stream. If the join is a left
   join or inner join, any inputs that do not match a dbfile record are 
   discarded. If the join is a right join or inner join, any db records that do
   not match an input record are discarded. 

   dbkey and inputkey may be key specs, see 'man recs' for more information

   For instance, if you did:
   recs-join type typeName dbfile fromfile

   with a db file like:
   { 'typeName': 'foo', 'hasSetting': 1 }
   { 'typeName': 'bar', 'hasSetting': 0 }

   and joined that with
   { 'name': 'something', 'type': 'foo'}
   { 'name': 'blarg', 'type': 'hip'}

   for an inner join, you would get
   { 'name': 'something', 'type': 'foo', 'typeName': 'foo', 'hasSetting': 1}

   for an outer join, you would get
   { 'name': 'something', 'type': 'foo', 'typeName': 'foo', 'hasSetting': 1}
   { 'name': 'blarg', 'type': 'hip'}
   { 'typeName': 'bar', 'hasSetting': 0 }

   for a left join, you would get
   { 'name': 'something', 'type': 'foo', 'typeName': 'foo', 'hasSetting': 1}
   { 'typeName': 'bar', 'hasSetting': 0 }

   for a right join, you would get
   { 'name': 'something', 'type': 'foo', 'typeName': 'foo', 'hasSetting': 1}
   { 'name': 'blarg', 'type': 'hip'}

Arguments:
   --help              Bail and output this help screen.
   --left              Do a left join
   --right             Do a right join
   --inner             Do an inner join (This is the default)
   --outer             Do an outer join
   --operation         An perl expression to evaluate for merging two records 
                       together, in place of the default behavior of db fields 
                       overwriting input fields. See "Operation" below.
   --accumulate-right  Accumulate all input records with the same key onto each
                       db record matching that key. See "Accumulate Right" 
                       below.

Operation:
   The expression provided is evaluated for every pair of db record and input
   record that have matching keys, in place of the default operation to 
   overwrite input fields with db fields. The variable \$d is set to a 
   Recs::Record object for the db record, and \$i is set to a Recs::Record 
   object for the input record. The \$d record is used for the result. Thus, if 
   you provide an empty operation, the result will contain only fields from the
   db record. 

Accumulate Right:
   Accumulate all input records with the same key onto each db record matching 
   that key. This means that a db record can have multiple input records merged
   into it. If no operation is provided, any fields in second or later records
   will be lost due to them being discarded. This option is most useful with a
   user defined operation to handle collisions. For example, one could provide
   an operation to add fields together:

   recs-join --left --operation '
     foreach \$k (keys \%\$i) {
       if (exists(\$d->{\$k})) {
         if (\$k =~ /^value/) {\$d->{\$k} = \$d->{\$k} + \$i->{\$k};}
       } else {
         \$d->{\$k} = \$i->{\$k};
       }
     }' --accumulate-right name name dbfile inputfile

Examples:
   Join type from STDIN and typeName from dbfile
      cat recs | recs-join type typeName dbfile
   
   Join host name from a mapping file to machines to get IPs
      recs-join host host hostIpMapping machines
USAGE
}

1;
