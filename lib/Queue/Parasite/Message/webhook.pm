package Queue::Parasite::Message::webhook;

use Moose::Role;

has webhook => ( is => 'rw', isa => 'Str' );
has pass    => ( is => 'rw', isa => 'Str' );
has fail    => ( is => 'rw', isa => 'Str' );


sub parse {
    my ($self) = @_;

    my $body = $self->decoded_body;

    if (ref($body->{webhook}) eq 'HASH') {
        $self->webhook($body->{webhook}{url});
        $self->pass($body->{webhook}{pass});
        $self->fail($body->{webhook}{fail});
    }
    else {
        $self->webhook($body->{webhook});
    }

}


sub process {
    my ($self) = @_;


}


1;

