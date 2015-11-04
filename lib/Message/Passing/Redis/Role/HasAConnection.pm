package Message::Passing::Redis::Role::HasAConnection;
use Moo::Role;
use Message::Passing::Redis::ConnectionManager;
use MooX::Types::MooseLike::Base qw/ Int /;
use namespace::clean -except => 'meta';

with qw/
    Message::Passing::Role::HasAConnection
    Message::Passing::Role::HasHostnameAndPort
/;
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
sub _default_port { 6379 }

sub _build_connection_manager {
    my $self = shift;
    Message::Passing::Redis::ConnectionManager->new(map { $_ => $self->$_() }
        qw/ hostname port reconnect every/
    );
}

1;

