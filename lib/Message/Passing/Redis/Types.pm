package Message::Passing::Redis::Types;
use MooseX::Types -declare => [qw/
    ArrayOfStr
/];

use MooseX::Types::Moose qw/ ArrayRef Str /;
use namespace::autoclean;

subtype ArrayOfStr,
    as ArrayRef[Str];

coerce ArrayOfStr,
    from Str,
    via { [ $_ ] };

1;

