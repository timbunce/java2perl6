package Java::Javap::Generator::TT;
use strict; use warnings;

use Template;
use Java::Javap::TypeCast;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub generate {
    shift;  # no use for invocant
    my $class_file = shift;
    my $ast        = shift;
    my $template   = shift;

    my $tt       = Template->new( {
        INCLUDE_PATH => 'templates',
        POST_CHOMP   => 1,
    } );

    my $tt_vars = {
        ast        => $ast,
        gen_time   => scalar localtime(),
        version    => '0.1',
        class_file => $class_file,
        type_caster=> Java::Javap::TypeCast->new(),
        command_line_flags => [
            '--classpath testjavas',
        ],
    };

    my $retval;
    $tt->process( $template, $tt_vars, \$retval ) || die $tt->error();

    return $retval;
}

1;
