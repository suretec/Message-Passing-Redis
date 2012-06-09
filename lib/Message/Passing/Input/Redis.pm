package Message::Passing::Input::Redis;
use Moose;
use Scalar::Util qw/ weaken /;
use Message::Passing::Redis::Types qw/ ArrayOfStr /;
use namespace::autoclean;

with qw/
    Message::Passing::Redis::Role::HasAConnection
    Message::Passing::Role::Input
/;

has topics => (
    isa => ArrayOfStr,
    coerce => 1,
    is => 'ro',
    default => sub { [] },
);

has ptopics => (
    isa => ArrayOfStr,
    coerce => 1,
    is => 'ro',
    default => sub { [] },
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
    ) if @{ $self->topics };
    $client->psubscribe(
        @{ $self->ptopics },
        sub {
            my ($message, $topic, $subscribed_topic) = @_;
            $self->output_to->consume($message);
        },
    ) if @{ $self->ptopics };
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

A list of topics to consume messages from.

These topic names are matched exactly.

=head2 ptopics

A list of pattern topics to consume messages from.

These topic names can wildcard match, so for example C<< prefix1.* >>
will match topics C<< prefix1.foo >> and C<< prefix1.bar >>.

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

