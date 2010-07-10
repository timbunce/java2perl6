use strict;
use warnings;

use lib 'lib';

use Test::Most;
use Java::Javap;
use Java::Javap::Grammar;
use Java::Javap::Generator;

plan skip_all => "javap from Java SDK required: $!"
	unless Java::Javap->javap_test();

plan tests    => 3;

#--------------------------------------------------------------------
# Grammar
#--------------------------------------------------------------------

my $parser = Java::Javap::Grammar->new();
my $decomp = Java::Javap->javap('com.example.NestedIntTest', {-classpath => 'testjavas'});
#diag("decomp=$decomp");

my $tree   = $parser->comp_unit( $decomp );
#diag("tree=", Dumper($tree));

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
                            'modifiers' => [ 'final' ],
                            'access' => 'public',
                            'name' => 'USELESS_CONSTANT',
                            'type' => {
                                name => 'int',
                                array_depth => 0,
                                array_text => '',
                            },
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
                                          [
                                          'java.lang.NumberFormatException'
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
my $caster = Java::Javap::TypeCast->new();
my $unique_types = Java::Javap->get_included_types( $tree, $caster );

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
$perl_6    =~ s/^\s+//;
#diag($perl_6);
my @perl_6 = split /\n/, $perl_6;
my @correct_perl_6 = split /\n/, <<'EO_Correct_Perl_6';
use v6;

class com::example::Second { ... };

role com::example::NestedIntTest {

    # our Int $USELESS_CONSTANT = ...; # int
    method USELESS_CONSTANT (--> Int) is export { ... }

    method array_returner(
        Str $v1,  # java.lang.String
        Int $v2,  # int
        Num @v3,  # float
        Num @v4,  # float
    --> Array    # Array of Array of  int
    ) { ... }

    multi method object_returner(
    --> Str   #  java.lang.String
    ) { ... }

    multi method object_returner(
        Str $v1,  # java.lang.String
    --> Str   #  java.lang.String
    ) { ... }

    method recurse_for_me(
    --> com::example::Second   #  com.example.Second
    ) { ... }

    method void_returner(
        Int $v1,  # int
    ) { ... }

};

EO_Correct_Perl_6

eq_or_diff( \@perl_6, \@correct_perl_6, 'emission' )
    or print "---vvv---\n$perl_6\n---^^^---\n";

