use strict;
use warnings;

use lib 'lib';

use Test::More tests => 1;
use Java::Javap::Grammar;
#use Java::Javap::Generator;

#--------------------------------------------------------------------
# Grammar
#--------------------------------------------------------------------

my $parser = Java::Javap::Grammar->new();
my $decomp = `javap -classpath testjavas ClassTest`;

my $tree   = $parser->comp_unit( $decomp );

my $expected_tree = {
          'compiled_from' => 'ClassTest.java',
          'parent' => 'java.lang.Object',
          'final' => undef,
          'qualified_name' => 'ClassTest',
          'access' => 'public',
          'contents' => [
                          {
                            'body_element' => 'constructor',
                            'access' => 'public',
                            'args' => [],
                            'throws' => [],
                            'native' => ''
                          },
                          {
                            'body_element' => 'constructor',
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_depth' => 1,
                                          'array_text' => 'Array of ',
                                          'name' => 'java.lang.String'
                                        },
                                      ],
                            'throws' => [],
                            'native' => ''
                          },
                          {
                            'body_element' => 'constructor',
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_depth' => 1,
                                          'array_text' => 'Array of ',
                                          'name' => 'java.lang.String'
                                        },
                                        {
                                          'array_depth' => 0,
                                          'array_text' => '',
                                          'name' => 'int'
                                        }
                                      ],
                            'throws' => [],
                            'native' => ''
                          },
                          {
                            'attrs' => [],
                            'body_element' => 'method',
                            'returns' => {
                                           'array_depth' => 0,
                                           'array_text' => '',
                                           'name' => 'java.lang.String'
                                         },
                            'access' => 'public',
                            'args' => [],
                            'name' => 'getGreet',
                            'throws' => []
                          },
                          {
                            'attrs' => [],
                            'body_element' => 'method',
                            'returns' => {
                                           'array_depth' => 0,
                                           'array_text' => '',
                                           'name' => 'java.lang.String'
                                         },
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_depth' => 0,
                                          'array_text' => '',
                                          'name' => 'int'
                                        },
                                      ],
                            'name' => 'getGreet',
                            'throws' => []
                          }
                        ],
          'class_or_interface' => 'class',
          'methods' => {
              getGreet => 2,
          },
          'constructors' => 3,
          'implements' => undef
};

is_deeply( $tree, $expected_tree, 'class' );

#--------------------------------------------------------------------
# Emission
#--------------------------------------------------------------------

#my $perl_6 = emit( 'ClassTest', $tree, 'interface.tt' );
#warn $perl_6;
#$perl_6    =~ s/^#.*//gm;
#my @perl_6 = split /\n/, $perl_6;
#
#my @correct_perl_6 = split /\n/, <<'EO_Correct_Perl_6';
#
#
#
#
#class? ClassTest {
#
#}
#EO_Correct_Perl_6
