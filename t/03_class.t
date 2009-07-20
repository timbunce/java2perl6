use strict;
use warnings;

use lib 'lib';

use Test::More;
use Java::Javap::Grammar;
use Java::Javap::Generator;

`javap`;
plan skip_all => 'javap from Java SDK required' if $!;
plan tests    => 3;

#--------------------------------------------------------------------
# Grammar
#--------------------------------------------------------------------

my $parser = Java::Javap::Grammar->new();
my $decomp = `javap -classpath testjavas ClassTest`;

my $tree   = $parser->comp_unit( $decomp );

my $expected_tree = {
          'compiled_from' => 'ClassTest.java',
          'parent' => 'java.lang.Object',
          'qualifiers' => [],
          'perl_qualified_name' => 'ClassTest',
          'java_qualified_name' => 'ClassTest',
          'access' => 'public',
          'contents' => [
                          {
                              'body_element' => 'variable',
                              'type' => {
                                  name => 'java.lang.String',
                                  array_depth => 0,
                                  array_text => '',
                              },
                              'access' => 'public',
                              'name' => 'var1',
                          },
                          {
                              'body_element' => 'variable',
                              'type' => {
                                  name => 'java.lang.String',
                                  array_depth => 0,
                                  array_text => '',
                              },
                              'access' => 'protected',
                              'name' => 'var2',
                          },
                          {
                              'body_element' => 'variable',
                              'type' => {
                                  name => 'java.lang.String',
                                  array_depth => 0,
                                  array_text => '',
                              },
                              'access' => '',
                              'name' => 'var3',
                          },
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

my $generator = Java::Javap::Generator->get_generator( 'Std' );
my $perl_6    = $generator->generate(
    {
        class_file  => 'ClassTest',
        ast         => $tree,
        javap_flags =>'--classpath testjavas'
    }
);
#warn $perl_6;
$perl_6    =~ s/^#.*//gm;
my @perl_6 = split /\n/, $perl_6;
#use Data::Dumper::Simple;
#diag($perl_6);
my @correct_perl_6 = split /\n/, <<'EO_Correct_Perl_6';





use java::lang::Object;

class ClassTest  is java::lang::Object {
    multi method getGreet(
        Int $v1, 
     --> Str    #  Str
    ) { ... }

    multi method getGreet(
     --> Str    #  Str
    ) { ... }

};
EO_Correct_Perl_6

is_deeply( \@perl_6, \@correct_perl_6, 'emission' );

#--------------------------------------------------------------------
# Emission - duplicate method removal
#--------------------------------------------------------------------
{
  my $parser = Java::Javap::Grammar->new();
  my $decomp = `javap -classpath testjavas dupMethodTest`;

  my $tree   = $parser->comp_unit( $decomp );

  my $generator = Java::Javap::Generator->get_generator( 'Std' );
  my $perl_6    = $generator->generate(
      {
          class_file  => 'dupMethodTest',
          ast         => $tree,
          javap_flags =>'--classpath testjavas',
          debug => 1,
      }
  );
  #warn $perl_6;
  $perl_6    =~ s/^#.*//gm;
  my @perl_6 = split /\n/, $perl_6;
#  diag("got: $perl_6");
  my @correct_perl_6 = split /\n/, <<'EO_Correct_Perl_6_a';





use java::lang::Object;

class dupMethodTest  is java::lang::Object {
    multi method dupMethod(
        Str @v1, 
     --> Str    #  Str
    ) { ... }

    multi method dupMethod(
        Int $v1, 
     --> Str    #  Str
    ) { ... }

    method nonDupedMethod(
        Int $v1, 
     --> Int    #  Int
    ) { ... }

};
EO_Correct_Perl_6_a

  is_deeply( \@perl_6, \@correct_perl_6, 'emission - duplicate method signatures removed' );
}