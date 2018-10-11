package Echobot;
use Mojo::Base 'Mojolicious';
use Carp 'croak';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');

  my $channel_secret = $self->config('channel_secret');
  my $channel_access_token = $self->config('channel_access_token');
  defined($channel_secret) && length($channel_secret) != 0
    or die('channel_secret is not set in config');
  defined($channel_access_token) && length($channel_secret) != 0
    or die('channel_access_token is not set in config');

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer') if $config->{perldoc};

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->post('/')->to('webhook#webhook');
}

1;
