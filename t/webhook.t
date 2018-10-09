#!/usr/bin/perl
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Echobot');

$t->post_ok('/webhook')
  ->status_is(200);

done_testing();

