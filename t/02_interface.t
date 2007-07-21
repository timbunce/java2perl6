use strict;
use warnings;

use lib 'lib';

use Test::More;
use Java::Javap;
use Java::Javap::Grammar;
use Java::Javap::Generator;

`javap`;
plan skip_all => 'javap from Java SDK required' if $!;
plan tests    => 3;

#--------------------------------------------------------------------
# Grammar
#--------------------------------------------------------------------

my $parser = Java::Javap::Grammar->new();
my $decomp = `javap -classpath testjavas com.example.NestedIntTest`;

my $tree   = $parser->comp_unit( $decomp );

my $expected_tree = {
          'compiled_from' => 'NestedIntTest.java',
          'parent' => undef,
          'qualifiers' => [],
          'perl_qualified_name' => 'com::example::NestedIntTest',
          'java_qualified_name' => 'com.example.NestedIntTest',
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
                          },
                          {
                            'attrs' => [
                                         'abstract'
                                       ],
                            'body_element' => 'method',
                            'returns' => {
                                           'array_text' => '',
                                           'array_depth' => 0,
                                           'name' => 'com.example.Second'
                                         },
                            'access' => 'public',
                            'args' => [],
                            'name' => 'recurse_for_me',
                            'throws' => []
                          },
                        ],
          'class_or_interface' => 'interface',
          'methods' => {
              'object_returner' => 2,
              'array_returner' => 1,
              'void_returner' => 1,
              'recurse_for_me' => 1,
          },
          constructors => undef,
          'implements' => undef,
};

is_deeply( $tree, $expected_tree, 'interface' );

#use Data::Dumper; warn Dumper( $tree );

#--------------------------------------------------------------------
# Finding unique types we need to traverse
#--------------------------------------------------------------------
my $unique_types = Java::Javap->get_included_types( $tree );

is_deeply( $unique_types, [ 'com.example.Second' ], 'unique_types' );

#--------------------------------------------------------------------
# Emission
#--------------------------------------------------------------------

my $generator = Java::Javap::Generator->get_generator( 'Std' );

my $perl_6 = $generator->generate(
    {
        class_file  => 'IntTest',
        ast         => $tree,
        javap_flags => '--classpath testjavas',
    }
);
#warn $perl_6;
$perl_6    =~ s/^#.*//gm;
my @perl_6 = split /\n/, $perl_6;

my @correct_perl_6 = split /\n/, <<'EO_Correct_Perl_6';





role com::example::NestedIntTest {

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

    method recurse_for_me(
    ) returns com::example::Second { ... }

}
EO_Correct_Perl_6

is_deeply( \@perl_6, \@correct_perl_6, 'emission' );

#use Data::Dumper; warn Dumper( $perl_6 );
