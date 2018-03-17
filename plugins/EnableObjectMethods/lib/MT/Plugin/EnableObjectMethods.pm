package MT::Plugin::EnableObjectMethods;
use strict;
use warnings;

use MT;
use MT::Plugin::EnableObjectMethods::Registry;

sub settings {
    my $class = shift;
    $class->instance->get_config_value('enable_object_methods') || {};
}

sub load_system_config_tmpl {
    my $class = shift;
    $class->instance->load_tmpl( 'system_config.tmpl',
        { enable_object_methods_loop => $class->_settings_loop },
    );
}

sub instance {
    my $class = shift;
    MT->component('EnableObjectMethods');
}

sub get_plugin_object_types {
    my $class = shift;
    my %types;
    for my $plugin ( map { $_->{object} } values %MT::Plugins ) {
        for my $type ( keys %{ $plugin->registry('object_types') || {} } ) {
            my $object = $plugin->registry( 'object_types', $type );
            next
                if $type =~ /\./
                || ref $object eq 'HASH';
            $types{$type} = 1;
        }
    }
    [ keys %types ];
}

sub generate_enable_object_methods {
    my $class = shift;
    my ($type) = @_;
    return undef
        if MT::Plugin::EnableObjectMethods::Registry->enable_object_methods(
        $type)
        && !( $class->settings->{$type} && %{ $class->settings->{$type} } );
    my $disable_object_methods
        = MT::Plugin::EnableObjectMethods::Registry->disable_object_methods(
        $type);
    if ($disable_object_methods) {
        +{  map {
                $_ => ref $disable_object_methods->{$_} eq 'CODE'
                    ? !$disable_object_methods->{$_}->()
                    : $disable_object_methods->{$_} ? 0
                    : 1
            } qw( delete edit save )
        };
    }
    elsif ( $class->settings->{$type} && %{ $class->settings->{$type} } ) {
        +{ map { $_ => ( $class->settings->{$type}{$_} ? 1 : 0 ) }
                qw( delete edit save ) };
    }
}

sub _settings_loop {
    my $class = shift;
    my $disable_object_methods
        = MT::Plugin::EnableObjectMethods::Registry->disable_object_methods;
    my @enable_object_methods;
    for my $type ( @{ $class->get_plugin_object_types } ) {
        next
            if MT::Plugin::EnableObjectMethods::Registry
            ->enable_object_methods($type)
            && !( $class->settings->{$type}
            && %{ $class->settings->{$type} } );
        push @enable_object_methods,
            +{
            type     => $type,
            disabled => $disable_object_methods ? 1 : 0,
            %{ $class->generate_enable_object_methods($type) || {} },
            };
    }
    +[ sort { $a->{type} cmp $b->{type} } @enable_object_methods ];
}

1;

