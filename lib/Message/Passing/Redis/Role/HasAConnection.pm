package Message::Passing::Redis::Role::HasAConnection;
use Moose::Role;
use namespace::autoclean;

has server => (
    is => 'ro',
    isa => 'Str',
    default => '127.0.0.1:6379',
);

with 'Message::Passing::Role::HasAConnection';
use Message::Passing::Redis::ConnectionManager;
sub _build_connection_manager {
    my $self = shift;
    Message::Passing::Redis::ConnectionManager->new(map { $_ => $self->$_() }
        qw/ server /
    );
}

1;

