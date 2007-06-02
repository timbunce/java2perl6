package Java::Javap::Emit;
use strict; use warnings;

use base 'Exporter';

our @EXPORT_OK = qw( emit );

use Template;
use Java::Javap::TypeCast;

sub emit {
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
        type_casts => Java::Javap::TypeCast->get_type_casts(),
        command_line_flags => [
            '--classpath testjavas',
        ],
    };

    my $retval;
    $tt->process( $template, $tt_vars, \$retval ) || die $tt->error();

    return $retval;
}
