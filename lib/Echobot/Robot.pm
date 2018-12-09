package Echobot::Robot;
use Mojo::Base -base;

use Carp;
use Regexp::Assemble;


has 'ra' => sub {
    Regexp::Assemble->new->track;
};

has 'callbacks' => sub {
    {}
};

sub hear {
    my $self = shift;
    my $re = shift;
    my $callback = shift;

    $self->ra->add($re);
    $self->callbacks->{$re} = $callback;
}

sub respond {
    my $self = shift;
    my $text = shift;

    my $matched = $self->ra->match($text);
    if ( $matched ) {
        $self->callbacks->{$matched}( $self->ra->mvar );
    } else {
        croak "cannot respond to '$text'";
    }
}

1;