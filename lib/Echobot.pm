package Echobot;
use Mojo::Base 'Mojolicious';
use Carp 'croak';

use Echobot::Robot;

# This method will run once at server start
sub startup {
    my $self = shift;

    # Load configuration from hash returned by "my_app.conf"
    my $config = $self->plugin('Config');

    my $channel_secret = $config->{channel_secret};
    my $channel_access_token = $config->{channel_access_token};
    $channel_secret or die('channel_secret is not set in config');
    $channel_access_token or die('channel_access_token is not set in config');

    $self->helper(line_message_api => sub {
        state $api = LINE::Bot::API->new(
            channel_secret => $channel_secret,
            channel_access_token => $channel_access_token
        );
        $api;
    });

    $self->helper(robot => sub {
        state $robot = setup_robot();
        $robot;
    });

    my $r = $self->routes;

    $r->post('/')->to('webhook#webhook');
}

sub setup_robot {
    my $robot = Echobot::Robot->new;

    $robot->hear(qr/こんにちは、((?:\p{InHiragana}|\p{InKatakana}|\p{InCJKunifiedideographs})+)。/, sub {
        my $matches = shift;
        $matches->[1];
    });

    $robot;
}

1;
