use strict;
use warnings;

use lib 'lib';

use Test::More tests => 2;
use Java::Javap::Grammar;
use Java::Javap::Emit qw( emit );

#--------------------------------------------------------------------
# Grammar
#--------------------------------------------------------------------

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
                                           'array_text' => 'Array of Array of ',
                                           'array_depth' => 2,
                                           'name' => 'int'
                                         },
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_text' => '',
                                          'array_depth' => 0,
                                          'name' => 'java.lang.String'
                                        },
                                        {
                                          'array_text' => '',
                                          'array_depth' => 0,
                                          'name' => 'int'
                                        },
                                        {
                                          'array_text' => 'Array of ',
                                          'array_depth' => 1,
                                          'name' => 'float'
                                        },
                                        {
                                          'array_text' => 'Array of Array of ',
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
                                           'array_text' => '',
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
                                           'array_text' => '',
                                           'array_depth' => 0,
                                           'name' => 'java.lang.String'
                                         },
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_text' => '',
                                          'array_depth' => 0,
                                          'name' => 'java.lang.String'
                                        },
                                      ],
                            'name' => 'object_returner',
                            'throws' => [
                                          'java.lang.NumberFormatException'
                                        ]
                          },
                          {
                            'attrs' => [
                                         'abstract'
                                       ],
                            'body_element' => 'method',
                            'returns' => {
                                           'array_text' => '',
                                           'array_depth' => 0,
                                           'name' => 'void'
                                         },
                            'access' => 'public',
                            'args' => [
                                        {
                                          'array_text' => '',
                                          'array_depth' => 0,
                                          'name' => 'int'
                                        }
                                      ],
                            'name' => 'void_returner',
                            'throws' => []
                          }
                        ],
          'class_or_interface' => 'interface',
          'methods' => {
              'object_returner' => 2,
              'array_returner' => 1,
              'void_returner' => 1,
          },
          constructors => undef,
          'implements' => undef,
};

is_deeply( $tree, $expected_tree, 'interface' );

#use Data::Dumper; warn Dumper( $tree );

#--------------------------------------------------------------------
# Emission
#--------------------------------------------------------------------

my $perl_6 = emit( 'IntTest', $tree, 'interface.tt' );
$perl_6    =~ s/^#.*//gm;
my @perl_6 = split /\n/, $perl_6;

my @correct_perl_6 = split /\n/, <<'EO_Correct_Perl_6';




role IntTest {

    method array_returner(
        Str v1,
        Int v2,
        Array of Num v3,
        Array of Array of Num v4,
    ) returns Array of Array of Int { ... }

    multi method object_returner(
    ) returns Str { ... }

    multi method object_returner(
        Str v1,
    ) returns Str { ... }

    method void_returner(
        Int v1,
    )  { ... }

}
EO_Correct_Perl_6

is_deeply( \@perl_6, \@correct_perl_6, 'emission' );

#use Data::Dumper; warn Dumper( $perl_6 );
