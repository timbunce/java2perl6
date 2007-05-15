use strict;
use warnings;

use lib 'lib';

use Test::More tests => 1;
use Java::Javap::Grammar;

my $parser = Java::Javap::Grammar->new();
my $decomp = `javap -classpath testjavas IntTest`;

my $tree   = $parser->comp_unit( $decomp );

my $expected_tree = {
          'compiled_from' => 'IntTest.java',
          'parent' => undef,
          'final' => undef,
          'qualified_name' => 'IntTest',
          'access' => 'public',
          'contents' => [
                          {
                            'body_element' => 'constant',
                            'final' => 'final',
                            'access' => 'public',
                            'name' => 'USELESS_CONSTANT',
                            'type' => 'int'
                          },
                          {
                            'attrs' => [
                                         'abstract'
                                       ],
                            'body_element' => 'method',
                            'returns' => {
                                           'array_depth' => 2,
                                           'name' => 'int'
                                         },
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_depth' => 0,
                                          'name' => 'java.lang.String'
                                        },
                                        {
                                          'array_depth' => 0,
                                          'name' => 'int'
                                        },
                                        {
                                          'array_depth' => 1,
                                          'name' => 'float'
                                        },
                                        {
                                          'array_depth' => 2,
                                          'name' => 'float'
                                        }
                                      ],
                            'name' => 'array_returner',
                            'throws' => []
                          },
                          {
                            'attrs' => [
                                         'abstract'
                                       ],
                            'body_element' => 'method',
                            'returns' => {
                                           'array_depth' => 0,
                                           'name' => 'java.lang.String'
                                         },
                            'access' => 'public',
                            'args' => [],
                            'name' => 'object_returner',
                            'throws' => [
                                          [
                                            'java.lang.NumberFormatException',
                                            'java.lang.Exception'
                                          ]
                                        ]
                          },
                          {
                            'attrs' => [
                                         'abstract'
                                       ],
                            'body_element' => 'method',
                            'returns' => {
                                           'array_depth' => 0,
                                           'name' => 'java.lang.String'
                                         },
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_depth' => 0,
                                          'name' => 'java.lang.String'
                                        },
                                      ],
                            'name' => 'object_returner',
                            'throws' => [
                                          'java.lang.NumberFormatException'
                                        ]
                          }
                        ],
          'class_or_interface' => 'interface',
          'implements' => undef
};

is_deeply( $tree, $expected_tree, 'interface' );
