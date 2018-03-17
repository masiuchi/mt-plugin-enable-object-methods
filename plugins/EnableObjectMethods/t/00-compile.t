use strict;
use warnings;

use Test::More;

use lib qw( lib extlib plugins/EnableObjectMethods/lib );

use_ok('MT::Plugin::EnableObjectMethods');
use_ok('MT::Plugin::EnableObjectMethods::Callback');
use_ok('MT::Plugin::EnableObjectMethods::Registry');

done_testing;

