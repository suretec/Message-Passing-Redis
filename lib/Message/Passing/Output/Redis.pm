package Message::Passing::Output::Redis;
use Moose;

with qw/
    Message::Passing::Redis::Role::HasAConnection
    Message::Passing::Role::Output
/;

has topic => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

sub consume {
    my $self = shift;
    my $data = shift;
    my $bytes = $self->encode($data);
    my $headers = undef;
    $self->connection_manager->connection->publish($self->topic, $bytes);
}

sub connected {}

__PACKAGE__->meta->make_immutable;
1;

