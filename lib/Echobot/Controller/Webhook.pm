package Echobot::Controller::Webhook;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Util qw|dumper|;
use Try::Tiny;
use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;

sub webhook {
  my $self = shift;

  my $app = $self->app;
  my $logger = $app->log;
  my $request = $self->req;
  my $headers = $request->headers;
  my $api = $app->line_message_api;

  my $x_line_signature = $headers->header('X-Line-Signature');

  unless ($api->validate_signature($request->body, $x_line_signature)) {
    $self->rendered(400);
    return;
  }
  $self->rendered(200);

  my $events = {};
  try {
    $events = $api->parse_events_from_json($request->body);
  } catch {
    $logger->fatal($_);
    $logger->debug($request->content);
  };

  return if $ENV{HARNESS_ACTIVE};

  for my $event (@{$events}) {
    if ($event->is_message_event
    ) {
      my $messages = LINE::Bot::API::Builder::SendMessage->new;

      if ($event->is_text_message) {
        $messages->add_text(text =>
          sprintf("%s曰く「%s・・・」",
            $event->is_user_event ? $api->get_profile($event->user_id)->display_name : 'グループの誰か',
            substr($event->text, 0, 6)))
          if int(rand 3) == 1;
      }

      $messages->add_text(text => 'もっと貼って！') if $event->is_image_message;

      $logger->debug('\n' . dumper($event));

      my $reply = $api->reply_message(
        $event->reply_token,
        $messages->build
      );

      unless ($reply->is_success) {
        for my $detail (@{$reply->details // []}) {
          $logger->fatal(sprintf('%s:%d:%s', __FILE__, __LINE__, $detail->{message}))
            if $detail && ref($detail) eq 'HASH';
        }
      }
    }
  }

}

1;