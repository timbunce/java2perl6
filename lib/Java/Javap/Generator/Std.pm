package Java::Javap::Generator::Std;
use strict; use warnings;

use Template;
use Java::Javap;
use Java::Javap::TypeCast;

# use Data::Dumper;

# XXX having this info here is suboptimal
# should at least be integrated with TypeCaster
# http://perlcabal.org/syn/S02.html#Undefined_types
my @perl_builtin_undefined = qw(
    Mu
    Failure
    Any
    Cool
);
# http://perlcabal.org/syn/S02.html#Immutable_types
my @perl_builtin_immutable = qw(
    Str
    Bit        
    Int       
    Num       
    Rat       
    FatRat
    Complex   
    Bool

    Exception 
    Block     
    Seq      
    Range   

    Set     
    Bag     
    Enum
    EnumMap
    Signature
    Parcel
    Slicel
    Capture
    Blob      
    Instant   
    Duration  
    HardRoutine
);
# http://perlcabal.org/syn/S02.html#Mutable_types
my @perl_builtin_mutable = qw(
    Iterator
    SeqIter
    RangeIter
    Scalar
    Array
    Hash
    KeySet
    KeyBag
    KeyHash
    Pair
    PairSeq
    Buf
    IO       
    Routine  
    Sub      
    Method   
    Submethod
    Macro    
    Regex    
    Match    
    Stash
    SoftRoutine

    DateTime
);
my @perl_builtin_roles = qw(
    Iterable
);
my $perl_builtin_types = { map { $_=>1 } (
        @perl_builtin_undefined,
        @perl_builtin_immutable,
        @perl_builtin_mutable,
        @perl_builtin_roles,
    ) };

sub new {
    my $class = shift;

    my $self = bless { @_ }, $class;

    my $tt_args = {
        POST_CHOMP => 1,
    };
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

    my $class_file  = $params->{class_file};
    my $ast         = $params->{ast};
    my $trace_level = defined $params->{trace_level} ? $params->{trace_level} : $self->{trace_level};
        
    $self->{type_caster} = $params->{type_caster} || Java::Javap::TypeCast->new();
    $self->_cast_names( $ast );
    
    $ast->{method_list} = $self->_get_unique_methods( $ast );
    #print STDERR Dumper($ast->{method_list});
    
    my $template    = $self->_get_template( $ast );

    my @prologue    = $self->_get_prologue( $ast );
    
    my $tt = Template->new( $self->tt_args );
    my $tt_vars = {
        ast        => $ast,
        gen_time   => scalar localtime(),
        version    => $Java::Javap::VERSION,
        class_file => $class_file,
        type_caster=> $self->{type_caster},
        javap_flags=> $params->{javap_flags},
        prologue   => \@prologue,
    };
    my $retval;
    $tt->process( \$template, $tt_vars, \$retval )
        or die "Error processing template: ".$tt->error();

    return $retval;
}

sub _cast_names {
    my $self    = shift;
    my $ast     = shift;
    
    my $type_caster = $self->{type_caster};
    my $class_parent = defined $ast->{parent} ? $type_caster->cast($ast->{parent}) : '';
    $ast->{cast_parent} = ($class_parent eq 'Mu') ? '' : $class_parent;
    foreach my $element (@{$ast->{contents}}) {
        #$element->{name} =~ s/\$/_/g if defined $element->{name};
            next unless $element->{body_element} eq 'method';
            
            foreach my $arg (@{$element->{args}}) {
                $arg->{cast_name} = $type_caster->cast($arg->{name});
        }
        $element->{returns}->{cast_name} = $type_caster->cast($element->{returns}->{name});
    }
}   

sub _get_unique_methods {
    my $self    = shift;
    my $ast     = shift;

    # identify duplicate signatures resulting from TypeCast operation
    # ie if both foo(javatype1) and foo(javatype2) get mapped to foo(perl_type)
    # then we only want to output foo once

    # retain only the methods
    my @methods =  grep { $_->{body_element} eq 'method' } @{$ast->{contents}} ;

    #print STDERR "methods: ", Dumper(@methods);
    my %meth;
    foreach my $element (@methods) {
        # discard method names containing '$' XXX why?
        next if $element->{name} =~ /\$/;
        #$element->{name} =~ s/\$/_/g if defined $element->{name};

        $element->{signature} = "$element->{name} ";

        foreach my $arg (@{$element->{args}}) {
            $element->{signature} .= (($arg->{array_text} =~ /Array of/) ? '@' : '$') .  "$arg->{cast_name}, ";
        }
        $element->{signature} .= " --> " . ($element->{returns}->{array_text} =~ /Array of/) ? 'Array' : $element->{returns}->{cast_name};
#       print STDERR "signature: '$element->{signature}'\n"   if $debug;
        # de-dup via hash
        $meth{$element->{signature}} = $element;
    }
    #print STDERR Dumper(%meth);
    @methods = sort {
        $a->{name} cmp $b->{name} or      # order by names first
        @{$a->{args}} <=> @{$b->{args}}   # and increasing arg count second
    } values %meth;
    #print STDERR Dumper(@methods);
    return \@methods;
}

sub _get_type_casts {
    my $self = shift;
    my $type_file = shift;

  # XXX TODO    
}

sub _get_prologue {
    my $self = shift;
    my $ast  = shift;

    my $type_caster = $self->{type_caster};
    my $trace_level = defined $self->{trace_level} ? $self->{trace_level} : 0;

    my %perl_types;
    if (defined $ast->{parent}) {
        my $target = $type_caster->cast($ast->{parent});
        $perl_types{$target}++;
    }
    
    foreach my $element (@{$ast->{contents}}) {

        next unless $element->{body_element} eq 'method';

        my $target = $type_caster->cast($element->{returns}->{name});
        $perl_types{$target}++;

        foreach my $arg (@{$element->{args}}) {
            my $target = $type_caster->cast($arg->{name});
            $perl_types{$target}++;
        }       
    }
    warn "$ast->{perl_qualified_name} references types: @{[ keys %perl_types ]}\n"
        if $trace_level >= 3;

    for my $perl_type (keys %perl_types) {
 
        delete $perl_types{$perl_type}
            if $perl_builtin_types->{$perl_type}
            # our own class name
            or $perl_type eq $ast->{perl_qualified_name}
            # private java class
            or $perl_type =~ /\$/
            # void java class
            or $perl_type eq 'void'
            # at the moment rakudo does not support 'Array of' so don't include the 
            # dependency on the class as it will just return Array at the moment.
            #or $element->{returns}->{array_text} =~ /Array of/;
            ;
    }
    warn "$ast->{perl_qualified_name} needs to load: @{[ keys %perl_types ]}\n"
        if $trace_level >= 3;

    # XXX ideally we'd use the class or role as appropriate but we don't need
    # to (at least for now) because: essentially  "class Foo { ... }"  simply
    # declares Foo as a package-ish identifier -- per pmichaud.
    # So we can get away with this cheat.
    return map { "class $_ { ... };" } sort keys %perl_types;
}


sub _get_template {
    my $self = shift;
    my $ast  = shift;

    my $prologue = $self->_get_template_prologue;
    my $method = "_get_template_for_".$ast->{ class_or_interface };
    return $prologue . $self->$method( $ast );
}

sub _get_template_prologue {
    return << 'EO_Template';
[% BLOCK file_header %]
# *** DO NOT EDIT *** CHANGES WILL BE LOST ***
# This file was automatically generated
# by java2perl6 [% version %] from decompiling
# [% class_file %] using command line flags:
#   [% javap_flags +%]

use v6;

[% END %]
[% BLOCK method_arg %]
        [% arg.cast_name %] [% arg.array_text.search('Array of') ? '@' : '$' %]v[% arg_counter %],  # [% arg.name +%]
[% END %]
[% BLOCK method_all_args %]
[% arg_counter = 0 %]
[% FOREACH arg IN elem.args %][% arg_counter = arg_counter + 1 %]
[% INCLUDE method_arg %]
[% END %]
[% END %]
[% BLOCK method_returns %]
[%- IF ret.name != 'void' %]    --> [% ret.array_text.search('Array of') ? 'Array ' : ret.cast_name %]
   # [%  ret.array_text %] [% ret.name +%]
[% END %]
[% END %]
EO_Template
}

sub _get_template_for_interface {
    return << 'EO_Template';
[% PROCESS file_header %]
[% FOREACH prologue_item IN prologue %]
[%+ prologue_item +%]
[% END %]

role [% ast.perl_qualified_name %][% IF ast.cast_parent != '' %] does [% ast.cast_parent %] [% END %] {
[% FOREACH element IN ast.method_list %]
    [% ast.methods.${ element.name } > 1 ? 'multi ' : '' %]method [% element.name %](  
[% INCLUDE method_all_args elem = element %]
[% INCLUDE method_returns ret = element.returns %]
    ) { ... }

[% END %]
};
EO_Template
}

sub _get_template_for_class {
    return << 'EO_Class_Template';
[% PROCESS file_header %]
[% FOREACH prologue_item IN prologue %]
[% prologue_item %]
[% END %]

class [% ast.perl_qualified_name %]
    [%- ast.cast_parent == '' ? '' : ' is ' %][% ast.cast_parent -%]
    [%- IF ast.implements != '' %] does [% ast.implements %] [% END -%]
{
[% FOREACH element IN ast.method_list %]
    [% ast.methods.${ element.name } > 1 ? 'multi ' : '' %]method [% element.name %](
[% INCLUDE method_all_args elem = element %]
[% INCLUDE method_returns ret = element.returns %]
    ) { ... }

[% END %]
};
EO_Class_Template
}

1;

__END__

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

Accessor for getting the TT constructor arguments.  Mainly for internal
use.

=back

=head1 EXPORT

Nothing, it's all OO

=head2 SEE ALSO

L<Java::Javap::Generator>
L<Java::Javap>
L<Java::Javap::Grammar>
L<java2perl6>

=head1 AUTHOR

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, Phil Crow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
vim: ts=8:sw=4:et
