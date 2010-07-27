
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Translate Java Class and Interface Definitions to Perl 6 Roles',
  'AUTHOR' => 'Tim Bunce <Tim.Bunce@pobox.com>',
  'BUILD_REQUIRES' => {},
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Java-2Perl6API',
  'EXE_FILES' => [
    'bin/java2perl6api',
    'bin/p5grammar'
  ],
  'LICENSE' => 'perl',
  'NAME' => 'Java::2Perl6API',
  'PREREQ_PM' => {
    'Parse::RecDescent' => '1.0',
    'Template' => '2.0',
    'Test::Differences' => '0',
    'Test::More' => '0.82',
    'Test::Most' => '0'
  },
  'VERSION' => '0.09',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



