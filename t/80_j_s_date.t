use strict;
use warnings;

use lib 'lib';

use Test::Most;
use Data::Dumper;

use Java::Javap;
use Java::Javap::Generator;
use Java::Javap::Grammar;

plan skip_all => "javap from Java SDK required: $!"
	unless Java::Javap->javap_test();

#--------------------------------------------------------------------
# Grammar
#--------------------------------------------------------------------

my $parser = Java::Javap::Grammar->new();
my $decomp = Java::Javap->javap('java.sql.Date', [ qw(-verbose) ]);

my $tree   = $parser->comp_unit( $decomp )
    or die "Error parsing:\n$decomp";

my $expected_tree = {
          'parent' => 'java.util.Date',
          'perl_qualified_name' => 'java::sql::Date',
          'qualifiers' => [],
          'access' => 'public',
          'contents' => [
                          {
                            'body_element' => 'constant',
                            'value' => '1511598038487230103',
                            'access' => '',
                            'name' => 'serialVersionUID',
                            'type' => {
                                        'array_depth' => 0,
                                        'array_text' => '',
                                        'name' => 'long'
                                      },
                            'modifiers' => [
                                             'final'
                                           ]
                          },
                          {
                            'body_element' => 'constructor',
                            'access' => 'public',
                            'name' => 'new',
                            'args' => [
                                        {
                                          'array_depth' => 0,
                                          'array_text' => '',
                                          'name' => 'int'
                                        },
                                        {
                                          'array_depth' => 0,
                                          'array_text' => '',
                                          'name' => 'int'
                                        },
                                        {
                                          'array_depth' => 0,
                                          'array_text' => '',
                                          'name' => 'int'
                                        }
                                      ],
                            'type' => {
                                        'array_depth' => 0,
                                        'name' => 'java.sql.Date',
                                        'array_text' => ''
                                      },
                            'throws' => [],
                            'native' => ''
                          },
                          {
                            'body_element' => 'constructor',
                            'access' => 'public',
                            'name' => 'new',
                            'args' => [
                                        {
                                          'array_depth' => 0,
                                          'array_text' => '',
                                          'name' => 'long'
                                        }
                                      ],
                            'type' => {
                                        'array_depth' => 0,
                                        'name' => 'java.sql.Date',
                                        'array_text' => ''
                                      },
                            'throws' => [],
                            'native' => ''
                          },
                          {
                            'attrs' => [],
                            'body_element' => 'method',
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_depth' => 0,
                                          'array_text' => '',
                                          'name' => 'long'
                                        }
                                      ],
                            'name' => 'setTime',
                            'type' => {
                                        'array_depth' => 0,
                                        'array_text' => '',
                                        'name' => 'void'
                                      },
                            'throws' => []
                          },
                          {
                            'attrs' => [
                                         'static'
                                       ],
                            'body_element' => 'method',
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_depth' => 0,
                                          'array_text' => '',
                                          'name' => 'java.lang.String'
                                        }
                                      ],
                            'name' => 'valueOf',
                            'type' => {
                                        'array_depth' => 0,
                                        'array_text' => '',
                                        'name' => 'java.sql.Date'
                                      },
                            'throws' => []
                          },
                          {
                            'attrs' => [],
                            'body_element' => 'method',
                            'access' => 'public',
                            'args' => [],
                            'name' => 'toString',
                            'type' => {
                                        'array_depth' => 0,
                                        'array_text' => '',
                                        'name' => 'java.lang.String'
                                      },
                            'throws' => []
                          },
                          {
                            'attrs' => [],
                            'body_element' => 'method',
                            'access' => 'public',
                            'args' => [],
                            'name' => 'getHours',
                            'type' => {
                                        'array_depth' => 0,
                                        'array_text' => '',
                                        'name' => 'int'
                                      },
                            'throws' => []
                          },
                          {
                            'attrs' => [],
                            'body_element' => 'method',
                            'access' => 'public',
                            'args' => [],
                            'name' => 'getMinutes',
                            'type' => {
                                        'array_depth' => 0,
                                        'array_text' => '',
                                        'name' => 'int'
                                      },
                            'throws' => []
                          },
                          {
                            'attrs' => [],
                            'body_element' => 'method',
                            'access' => 'public',
                            'args' => [],
                            'name' => 'getSeconds',
                            'type' => {
                                        'array_depth' => 0,
                                        'array_text' => '',
                                        'name' => 'int'
                                      },
                            'throws' => []
                          },
                          {
                            'attrs' => [],
                            'body_element' => 'method',
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_depth' => 0,
                                          'array_text' => '',
                                          'name' => 'int'
                                        }
                                      ],
                            'name' => 'setHours',
                            'type' => {
                                        'array_depth' => 0,
                                        'array_text' => '',
                                        'name' => 'void'
                                      },
                            'throws' => []
                          },
                          {
                            'attrs' => [],
                            'body_element' => 'method',
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_depth' => 0,
                                          'array_text' => '',
                                          'name' => 'int'
                                        }
                                      ],
                            'name' => 'setMinutes',
                            'type' => {
                                        'array_depth' => 0,
                                        'array_text' => '',
                                        'name' => 'void'
                                      },
                            'throws' => []
                          },
                          {
                            'attrs' => [],
                            'body_element' => 'method',
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_depth' => 0,
                                          'array_text' => '',
                                          'name' => 'int'
                                        }
                                      ],
                            'name' => 'setSeconds',
                            'type' => {
                                        'array_depth' => 0,
                                        'array_text' => '',
                                        'name' => 'void'
                                      },
                            'throws' => []
                          }
                        ],
          'class_or_interface' => 'class',
          'compiled_from' => 'Date.java',
          'java_qualified_name' => 'java.sql.Date',
          'methods' => {
                         'getSeconds' => 1,
                         'setSeconds' => 1,
                         'getHours' => 1,
                         'getMinutes' => 1,
                         'setMinutes' => 1,
                         'setTime' => 1,
                         'toString' => 1,
                         'valueOf' => 1,
                         'setHours' => 1,
                         'new' => 2
                       },
          'constructors' => 2,
          'implements' => undef
        };

is_deeply( $tree, $expected_tree, 'class' )
    or print "---vvv---\n".Dumper($tree)."---^^^---\n";

# -- parse tricky classes to check they at least parse ok

sub parse_class {
    my ($class) = @_;
    my $decomp = Java::Javap->javap($class, [ qw(-verbose) ]);
    my $tree = $parser->comp_unit( $decomp );
    return $tree;
}

# java.sql.DriverManager has Deprecated:, Signature:, and "static {};"
# java.sql.Time has RuntimeVisibleAnnotations:

ok parse_class($_) for (qw(
    java.sql.DriverManager
    java.sql.Time
));

done_testing();

