package Echobot::Controller::Webhook;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Util qw|dumper|;
use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;

sub webhook {
    my $self = shift;

    my $app = $self->app;
    my $logger = $app->log;
    my $request = $self->req;
    my $headers = $request->headers;
    my $api = $self->line_message_api;
    my $robot = $self->robot;

    my $x_line_signature = $headers->header('X-Line-Signature');

    unless ($api->validate_signature($request->body, $x_line_signature)) {
        $self->rendered(400);
        return;
    }
    $self->rendered(200);

    my $events = {};
    eval {
        $events = $api->parse_events_from_json($request->body);
        1;
    } or do {
        $logger->fatal($_);
        $logger->debug($request->content);
        return;
    };

    return if $ENV{HARNESS_ACTIVE};

    for my $event (@{$events}) {
        next unless $event->is_message_event;
        my $messages = LINE::Bot::API::Builder::SendMessage->new;

        if ($event->is_text_message) {
            my $text;
            eval {
                $text = $self->robot->respond( $event->text );
                1;
            } and do {
                $messages->add_text( text => $text );
            };
        }

        my $built_messages = $messages->build;
        my $count = @{$built_messages};
        return if ($count == 0);

        my $reply = $api->reply_message(
            $event->reply_token,
            $built_messages
        );

        unless ($reply->is_success) {
            for my $detail ( @{ $reply->details // [] } ) {
                my $warning = sprintf('detail: %s', $detail->{message});
                $logger->fatal($warning);
            }
        }
    }
}

1;