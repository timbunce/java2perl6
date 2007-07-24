use 5.008006;
use ExtUtils::MakeMaker;
use File::Spec;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $java2perl6 = File::Spec->catfile( 'bin', 'java2perl6' );

WriteMakefile(
    NAME              => 'Java::Javap',
    VERSION_FROM      => 'lib/Java/Javap.pm', # finds $VERSION
    PREREQ_PM         => {
        Template => '2.0',
        Parse::RecDescent => '1.0',
    }, # e.g., Module::Name => 1.1
    EXE_FILES         => [ $java2perl6 ],
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Java/Javap.pm', # retrieve abstract from module
       AUTHOR         => 'Philip Crow <phil@apple.com>') : ()),
);

sub MY::postamble {
return <<'MAKE_FRAG';
all ::
	cd lib/Java/Javap && perl -MParse::RecDescent - javap.grammar Java::Javap::Grammar

MAKE_FRAG
}
