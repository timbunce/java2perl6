use 5.008006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Java::Javap',
    VERSION_FROM      => 'lib/Java/Javap.pm', # finds $VERSION
    PREREQ_PM         => {
        Template => '2.0',
        Parse::RecDescent => '1.0',
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Java/Javap.pm', # retrieve abstract from module
       AUTHOR         => 'Philip Crow <phil@apple.com>') : ()),
);
