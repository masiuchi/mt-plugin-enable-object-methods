package MT::Plugin::EnableObjectMethods::Callback;
use strict;
use warnings;

use MT;
use MT::Plugin::EnableObjectMethods;
use MT::Plugin::EnableObjectMethods::Registry;

sub init_app {
    my $enable_object_methods_core
        = MT::Plugin::EnableObjectMethods::Registry
        ->enable_object_methods_core;
    for my $type (
        @{ MT::Plugin::EnableObjectMethods->get_plugin_object_types } )
    {
        my $type_enable_object_methods = MT::Plugin::EnableObjectMethods
            ->generate_enable_object_methods($type);
        $enable_object_methods_core->{$type} = $type_enable_object_methods
            if $type_enable_object_methods;
    }
}

sub save_config_filter {
    my ( $cb, $plugin, $data, $scope ) = @_;
    my @params = ( $data->{enable_object_methods} );
    @params = @{ $params[0] } if ref $params[0] eq 'ARRAY';
    $data->{enable_object_methods}
        = _generate_enable_object_methods( \@params );
    MT->app->reboot;
    1;
}

sub _generate_enable_object_methods {
    my ($params) = @_;
    my %enable_object_methods;
    for my $param (@$params) {
        next unless $param =~ /^(.+):(delete|edit|save)$/;
        my $type   = $1;
        my $method = $2;
        $enable_object_methods{$type}{$method} = 1;
    }
    \%enable_object_methods;
}

sub system_config_tmpl {
    MT::Plugin::EnableObjectMethods->load_system_config_tmpl;
}

1;

