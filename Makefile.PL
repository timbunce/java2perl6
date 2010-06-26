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
    ABSTRACT_FROM     => 'lib/Java/Javap.pm', # retrieve abstract from module
    AUTHOR            => 'Philip Crow <phil@apple.com>',
);

sub MY::postamble {
    return unless -d ".git" or -d ".svn"; # ignore for non-developers
return <<'MAKE_FRAG';
all :: lib/Java/Javap/Grammar.pm

lib/Java/Javap/Grammar.pm: lib/Java/Javap/javap.grammar
	cd lib/Java/Javap && perl -MParse::RecDescent - javap.grammar Java::Javap::Grammar

MAKE_FRAG
}
