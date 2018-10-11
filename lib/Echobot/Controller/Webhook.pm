package Echobot::Controller::Webhook;
use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny;
use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;

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

  my $events = {};
  try {
    $events = $bot->parse_events_from_json($request->body);
  } catch {
    $logger->fatal($_);
    $logger->debug($request->content);
  };

  return if $ENV{HARNESS_ACTIVE};

  for my $event (@{$events}) {
    if ($event->is_user_event
        && $event->is_message_event
        && $event->is_text_message
    ) {
      my $messages = LINE::Bot::API::Builder::SendMessage->new;
      $messages->add_text(text => $event->text);

      my $reply = $bot->reply_message(
        $event->reply_token,
        $messages->build
      );

      unless ($reply->is_success) {
        for my $detail (@{$reply->details // {}}) {
          $logger->fatal($detail->{message})
            if $detail && ref($detail) eq 'HASH';
        }
      }
    }
  }

}

1;