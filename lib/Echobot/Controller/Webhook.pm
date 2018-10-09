package Echobot::Controller::Webhook;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::UserAgent;
use Mojo::JSON 'decode_json';
use Mojo::JSON::Pointer;
use Mojo::Util 'dumper';

use Echobot::Util qw(verify_line_signature);

sub webhook {
  my $self = shift;

  my $app = $self->app;
  my $log = $app->log;

  my $channel_secret = $app->config('channel_secret');
  my $channel_access_token = $app->config('channel_access_token');

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

  my $decoded = decode_json($req_body);
  my $pointer = Mojo::JSON::Pointer->new($decoded);
  my $events = $pointer->get('/events');

  $log->debug(dumper $events);

  my $ua = Mojo::UserAgent->new;

  for my $event (@{$events}) {
    my $reply_token = $event->{replyToken};
    my $text = $event->{message}->{text};

    $ua->post(
      'https://api.line.me/v2/bot/message/reply'
      => {Authorization  => "Bearer $channel_access_token"}
      => json => {
        replyToken => $reply_token,
        messages   => [
          {
            type => 'text',
            text => $text
          }
        ]
      }
    );
  }

  $self->render(data => '');
}

1;