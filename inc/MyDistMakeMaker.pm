package inc::MyDistMakeMaker;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_MakeFile_PL_template => sub {
    my ($self) = @_;
    my $template = super();

    $template .= <<'TEMPLATE';
package MY;

sub postamble {
    return unless -d ".git" or -d ".svn"; # ignore for non-developers
return <<'MAKE_FRAG';
all :: lib/Java/Javap/Grammar.pm

lib/Java/Javap/Grammar.pm: lib/Java/Javap/javap.grammar
        cd lib/Java/Javap && perl -MParse::RecDescent - javap.grammar Java::Javap::Grammar

MAKE_FRAG
}
TEMPLATE

    return $template;
};

__PACKAGE__->meta->make_immutable;
