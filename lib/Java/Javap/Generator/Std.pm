package Java::Javap::Generator::Std;
use strict; use warnings;
our $VERSION = 0.0.5;

use Template;
use Java::Javap;
use Java::Javap::TypeCast;

sub new {
    my $class   = shift;
    my $tt_args = { POST_CHOMP => 1 };

    my $self    = bless { }, $class;
    $self->tt_args_set( $tt_args );

    return $self;
}

sub tt_args_set {
    my $self = shift;
    my $args = shift;

    $self->{__TT_ARGS__} = $args;
}

sub tt_args {
    my $self = shift;
    return $self->{__TT_ARGS__};
}

sub generate {
    my $self        = shift;
    my $params      = shift;

    my $class_file  = $params->{ class_file  };
    my $ast         = $params->{ ast         };
    my $javap_flags = $params->{ javap_flags };

    my $template    = $self->_get_template( $ast );

    my $tt         = Template->new( $self->tt_args );
    my @modules    = $self->_get_modules($ast);
    my $tt_vars = {
        ast        => $ast,
        gen_time   => scalar localtime(),
        version    => $Java::Javap::VERSION,
        class_file => $class_file,
        type_caster=> Java::Javap::TypeCast->new(),
        javap_flags=> $javap_flags,
        modules    => \@modules,
    };

    my $retval;
    $tt->process( \$template, $tt_vars, \$retval ) || die $tt->error();

    return $retval;
}

sub _get_template {
    my $self = shift;
    my $ast  = shift;

    my $method = "_get_template_for_$ast->{ class_or_interface }";

    return $self->$method( $ast );
}

sub _get_modules {
    my $self = shift;
    my $ast  = shift;
    
    my %mod;
    my %ignore = ( Str => 1, Int => 1, Bool => 1, void => 1);
    
    use Data::Dumper::Simple;
    #print STDERR Dumper($ast);
    my $target;
    foreach my $element (@{$ast->{contents}}) {
        #print STDERR Dumper($element);
        next unless $element->{body_element} eq 'method';
        $target = Java::Javap::TypeCast->new()->cast($element->{returns}->{name});
        next if $ignore{$target};
        next if $target =~ /^$ast->{perl_qualified_name}\s*$/;
        $mod{$target}++;
        
        foreach my $arg (@{$element->{args}}) {
            $target = Java::Javap::TypeCast->new()->cast($arg->{name});
            next if $ignore{$target};
            $mod{$target}++;
        }       
    }
    return keys %mod;
}

sub _get_template_for_interface {
    return << 'EO_Template';
# This file was automatically generated [% gen_time +%]
# by java2perl6 [% version %] from decompiling
# [% class_file %] using command line flags:
#   [% javap_flags +%]
[% FOREACH package IN modules %]
use [% package -%];
[% END %]

role [% ast.perl_qualified_name %] {
[% FOREACH element IN ast.contents %]
[% IF element.body_element == 'method' %]
[% IF ast.methods.${ element.name } > 1 %]
    multi method [% element.name %](
[% ELSE %]
    method [% element.name %](
[% END %][% arg_counter = 0 %]
[% FOREACH arg IN element.args %][% arg_counter = arg_counter + 1 %]
        [% arg.array_text %][% type_caster.cast( arg.name ) %] [% arg.array_text.search('Array of') ? '@' : '$' %]v[% arg_counter %], 
[% END %]
    [% IF element.returns.name != 'void' %] --> [% element.returns.array_text %][% type_caster.cast( element.returns.name ) %][% END %] ) { ... }
[% END %]

[% END %]
}
EO_Template
}

sub _get_template_for_class {
    return << 'EO_Class_Template';
# This file was automatically generated [% gen_time +%]
# by java2perl6 [% version %] from decompliling
# [% class_file %] using command line flags:
#   [% javap_flags +%]

[% FOREACH package IN modules %]
use [% package -%];
[% END %]

class [% ast.perl_qualified_name %] {
[% FOREACH element IN ast.contents %]
[%  IF element.body_element == 'method' %]
[%      IF ast.methods.${ element.name } > 1 %]
    multi method [% element.name %](
[%      ELSE %]
    method [% element.name %](
[%      END %][% arg_counter = 0 %]
[%      FOREACH arg IN element.args %][% arg_counter = arg_counter + 1 %]
        [% arg.array_text %][% type_caster.cast( arg.name ) %] [% arg.array_text.search('Array of') ? '@' : '$' %]v[% arg_counter %], 
[%      END %]
    [% IF element.returns.name != 'void' %] --> [% element.returns.array_text %][% type_caster.cast( element.returns.name ) %][% END %] ) { ... }
[%  ELSE %]
[%# I spy with my little eye, I spy a constructor %]
[%  END %]

[% END %]
}
EO_Class_Template
}

1;

=head1 NAME

Java::Javap::Generator::Std - uses TT to spit out Perl 6

=head1 SYNOPSIS

    useJava::Javap::Generator; 
    my $gen = Java::Javap::Generator->get_generator( 'Std' );
    my $output = $gen->generate(
        {
            $class_file  => 'com.example.InterfaceName',
            $ast         => $tree,
            $javap_flags => $javap_flags,
        }
    );

where C<$tree> is a Java::Javap abstract syntax tree (AST).  Note that
parameters are named.

=head1 DESCRIPTION

This is a generator which uses TT to make output.  It's templates are
strings inside this module.  To change templates, subclass and override
C<_get_template_for_interface> and/or C<_get_template_for_class>.

=head1 METHODS

=over 4

=item get_generator

Call this as a class method on C<Java::Javap::Generator>.  Pass it
C<Std> to ask it for an instance of this class.

=item generate

This is the workhorse of this module.  It takes information about your
java .class file and generates Perl 6 code.

Parameters (these are named, pass them in a hashref, see below):

=over 4

=item class_file

for documentation, the name of the java .class file

=item ast

the syntax tree you got from the parser

=item javap_flags

for documentation, the flags used on the javap command line

=back

Use C<Java::Javap::Grammar> to generate the ast.

Example:

 my $parser = Java::Javap::Grammar->new();
 my $decomp = `javap com.example.SomeInterface`;
 my $tree   = $parser->comp_unit( $decomp );
 my $jenny  = Java::Javap::Generator->get_generator( 'Std' );
 my $output = $jenny->generate( 
      {
          class_file  => $class_file,
          ast         => $tree,
      }
 );

=item new

For use by C<Java::Javap::Generator>.  You could call it directly, that
would bypass the factory.

=item tt_args_set

By default, the TT objects used internally will have this TT constructor
parameter:

    { POST_CHOMP   => 1 }

Use this accessor to change the TT constructor arguments.  You may call this
at any time.  The C<new> method uses this accessor.

Since C<generate> makes a new TT object for each call, any changes you
make via this method will apply to subsequent calls.

=item tt_args

Accessr for getting the TT constructor arguments.  Mainly for internal
use.

=back

=head1 EXPORT

Nothing, it's all OO

=head2 SEE ALSO

    Java::Javap::Generator
    Java::Javap
    Java::Javap::Grammar
    java2perl6

=head1 AUTHOR

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, Phil Crow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
