use strict;
use warnings;

use lib 'lib';

use Test::More;
use Java::Javap::Grammar;
use Java::Javap::Generator;

system('javap');
plan skip_all => "javap from Java SDK required: $!" if $!;
plan tests    => 1;

#--------------------------------------------------------------------
# Grammar
#--------------------------------------------------------------------

my $parser = Java::Javap::Grammar->new();
my $decomp = `javap -classpath testjavas FinalClassTest`;

my $tree   = $parser->comp_unit( $decomp );

my $expected_tree = {
          'compiled_from' => 'FinalClassTest.java',
          'parent' => 'java.lang.Object',
          'qualifiers' => [ 'final' ],
          'perl_qualified_name' => 'FinalClassTest',
          'java_qualified_name' => 'FinalClassTest',
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
                            'attrs' => [ 'final' ],
                            'body_element' => 'method',
                            'returns' => {
                                           'array_depth' => 0,
                                           'array_text' => '',
                                           'name' => 'java.lang.String'
                                         },
                            'access' => 'public',
                            'args' => [],
                            'name' => 'openStream',
                            'throws' => []
                          },
                        ],
          'class_or_interface' => 'class',
          'methods' => {
              openStream => 1,
          },
          'constructors' => 1,
          'implements' => undef
};

is_deeply( $tree, $expected_tree, 'final class' );

