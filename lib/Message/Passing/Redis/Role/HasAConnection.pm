package Message::Passing::Redis::Role::HasAConnection;
use Moose::Role;
use namespace::autoclean;

has hostname => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has port => (
    is => 'ro',
    isa => 'Int',
    default => 6379,
);

with 'Message::Passing::Role::HasAConnection';
use Message::Passing::Redis::ConnectionManager;
sub _build_connection_manager {
    my $self = shift;
    Message::Passing::Redis::ConnectionManager->new(map { $_ => $self->$_() }
        qw/ hostname port /
    );
}

1;

