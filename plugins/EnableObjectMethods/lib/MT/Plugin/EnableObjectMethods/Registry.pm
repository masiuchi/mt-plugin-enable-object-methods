package MT::Plugin::EnableObjectMethods::Registry;
use strict;
use warnings;

use MT;

sub disable_object_methods {
    my $class = shift;
    MT->registry( 'applications', 'cms', 'disable_object_methods', @_ );
}

sub enable_object_methods {
    my $class = shift;
    MT->registry( 'applications', 'cms', 'enable_object_methods', @_ );
}

sub enable_object_methods_core {
    my $class = shift;
    MT->component('core')
        ->registry( 'applications', 'cms', 'enable_object_methods', @_ );
}

1;

