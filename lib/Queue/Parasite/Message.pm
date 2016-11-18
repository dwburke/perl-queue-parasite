package Queue::Parasite::Message;

use Moose;
use JSON;
use Moose::Util qw( apply_all_roles );
use namespace::autoclean;

has type => ( is => 'ro', isa => 'Str' );

has data => ( is => 'rw', isa => 'HashRef', required => 1 );

has body => ( is => 'ro', isa => 'Str', init_arg => undef, lazy => 1, default => sub { $_[0]->data->{body} } );
has decoded_body => (
    is => 'ro',
    isa => 'Str | HashRef',
    init_arg => undef,
    lazy => 1,
    builder => '_builder_decode_body',
);


sub _builder_decode_body {
    my $self = shift;
    from_json( $self->data->{body} );
}


sub BUILD {
    my ($self) = @_;

    my $type = $self->type($self->decoded_body->{type});

    my $role = ($type =~ /::/) ? $type : 'Queue::Parasite::Message::' . $type;

    apply_all_roles( $self, $role );

    $self->parse;
}


__PACKAGE__->meta->make_immutable;

1;

