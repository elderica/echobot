#!/usr/bin/perl
use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Test::Exception;

dies_ok {
  my $t = Test::Mojo->new('Echobot' => {
    channel_secret       => undef,
    channel_access_token => undef
  });
} 'configuration needed';

done_testing();