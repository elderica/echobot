package Echobot::Controller::Webhook;
use Mojo::Base 'Mojolicious::Controller';

use Echobot::Util qw(verify_line_signature);

sub webhook {
  my $self = shift;

  my $app = $self->app;
  my $log = $app->log;

  my $channel_secret = $app->config('channel_secret');

  $log->fatal('channel_secret is not set in config')
    unless defined($channel_secret);

  my $req = $self->req;
  my $req_body = $req->body;
  my $headers = $req->headers;
  my $x_line_signature = $headers->header('X-Line-Signature');

  $log->debug($req_body);

  $log->debug($x_line_signature);

  $log->debug(
    verify_line_signature($channel_secret, $x_line_signature, $req_body)
      ? 'signature is ok'
      : 'signature is bad'
  );

  $self->render(data => '');
}

1;