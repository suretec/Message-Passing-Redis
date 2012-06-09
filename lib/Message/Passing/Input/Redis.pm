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
            $self->output_to->consume($message);
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

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

Message::Passing::Input::Redis - A Redis consumer for Message::Passing

=head1 SYNOPSIS

    $ message-passing --output STDOUT --input Redis --input_options '{"topics":["foo"],"server":"127.0.0.1:6379"}'

=head1 DESCRIPTION

A simple subscriber a Redis PubSub topic

=head1 ATTRIBUTES

=head2 server

The hostname and port number of the Redis server. Defaults to C<< 127.0.0.1:6379 >>.

=head2 topics

The list of topics to consume messages from.

=head1 METHODS

=head2 connected

Called by L<Message::Passing::Redis::ConnectionManager> to indicate a
connection to the Redis server has been made.

Causes the subscription to the topic(s) to be started

=head2 disconnect

Called by L<Message::Passing::Redis::ConnectionManager> to indicate a
connection to the Redis server has failed.

=head1 SEE ALSO

=over

=item L<Message::Passing::Output::Redis>

=item L<Message::Passing::Redis>

=back

=head1 AUTHOR, COPYRIGHT AND LICENSE

See L<Message::Passing::Redis>.

=cut

