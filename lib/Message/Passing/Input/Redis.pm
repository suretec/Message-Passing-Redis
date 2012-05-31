package Message::Passing::Input::Redis;
use Moose;
use Scalar::Util qw/ weaken /;
use namespace::autoclean;

with qw/
    Message::Passing::Redis::Role::HasAConnection
    Message::Passing::Role::Input
/;

has topics => (
    isa => 'ArrayRef[Str]',
    is => 'ro',
    required => 1,
);

has _handle => (
    is => 'rw',
    clearer => '_clear_handle',
);

sub connected {
    my ($self, $client) = @_;
    weaken($self);
    weaken($client);
    $client->subscribe(
        @{ $self->topics },
        sub {
            my ($message, $topic, $subscribed_topic) = @_;
            $self->output_to->consume($self->decode($message));
        },
    );
    $self->_handle(AnyEvent->io(
        fh   => $client->{sock},
        poll => "r",
        cb   => sub {
            $client->wait_for_messages(0);
        },
    ));
}

sub disconnect {
    my ($self) = @_;
    $self->_clear_handle;
}

1;

