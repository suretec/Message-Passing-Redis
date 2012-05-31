package Message::Passing::Redis::ConnectionManager;
use Moose;
use Scalar::Util qw/ weaken /;
use Redis;
use namespace::autoclean;

with 'Message::Passing::Role::ConnectionManager';

has server => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

sub _build_connection {
    my $self = shift;
    weaken($self);
    my $client = Redis->new(
        encoding => undef,
        server => $self->server,
    );
    # Delay calling set_connected till we've finished building the client
    my $i; $i = AnyEvent->idle(cb => sub {
        undef $i; $self->_set_connected(1);
    });
    return $client;
}

__PACKAGE__->meta->make_immutable;
1;

