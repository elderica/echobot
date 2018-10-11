package Echobot::Controller::Webhook;
use Mojo::Base 'Mojolicious::Controller';

use LINE::Bot::API;

sub webhook {
  my $self = shift;

  my $app = $self->app;
  my $logger = $app->log;
  my $request = $self->req;
  my $headers = $request->headers;

  my $bot = LINE::Bot::API->new(
    channel_secret => $self->config('channel_secret'),
    channel_access_token => $self->config('channel_access_token')
  );

  my $x_line_signature = $headers->header('X-Line-Signature');

  unless ($bot->validate_signature($request->body, $x_line_signature)) {
    $self->rendered(400);
    return;
  }
  $self->rendered(200);
}

1;