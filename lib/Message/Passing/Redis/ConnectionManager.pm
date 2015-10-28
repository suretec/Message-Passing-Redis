package Message::Passing::Redis::ConnectionManager;
use Moo;
use MooX::Types::MooseLike::Base qw/ Int /;
use Scalar::Util qw/ weaken /;
use Redis;
use AnyEvent;
use namespace::clean -except => 'meta';

with qw/
    Message::Passing::Role::ConnectionManager
    Message::Passing::Role::HasHostnameAndPort
/;

sub _default_port { 6379 }

has reconnect => (
    isa => Int,
    is  => 'ro',
    default => sub { 0 },
);
has every => (
    isa => Int,
    is => 'ro',
    default => sub { 0 },
);
sub _build_connection {
    my $self = shift;
    weaken($self);
    my $client = Redis->new(
        encoding => undef,
        server => sprintf("%s:%s", $self->hostname, $self->port),
        ($self->reconnect && $self->every
            ? (reconnect => $self->reconnect, every => $self->every)
            : ()
        ),
    );
    # Delay calling set_connected till we've finished building the client
    my $i; $i = AnyEvent->idle(cb => sub {
        undef $i; $self->_set_connected(1);
    });
    return $client;
}

1;

