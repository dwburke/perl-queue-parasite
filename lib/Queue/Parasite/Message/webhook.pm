package Queue::Parasite::Message::webhook;

use Moose::Role;
use LWP::UserAgent;


has url  => ( is => 'rw', isa => 'Str' );
has pass => ( is => 'rw', isa => 'Str' );
has fail => ( is => 'rw', isa => 'Str' );

has ua => ( is => 'rw', isa => 'LWP::UserAgent', builder => '_builder_ua' );

sub parse {
    my ($self) = @_;

    my $body = $self->decoded_body;

    if (ref($body->{webhook}) eq 'HASH') {
        $self->url($body->{webhook}{url});
        $self->pass($body->{webhook}{pass});
        $self->fail($body->{webhook}{fail});
    }
    else {
        $self->url($body->{webhook});
    }

}


sub process {
    my ($self) = @_;

    my $ua = $self->ua;

    # other method support forthcoming
    my $response = $ua->get( $self->url );

    if ($response->is_success) {
        if ($self->pass) {
            my $pass_response = $ua->get( $self->pass );
            die $pass_response->decoded_content unless $pass_response->is_success;
        }
    }
    elsif ($self->fail) {
        my $fail_response = $ua->get( $self->fail );
        die $fail_response->decoded_content unless $fail_response->is_success;
    }
    else {
        die $response->decoded_content unless $response->is_success;
    }

}


sub _builder_ua { 
    my ($self) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;

    $ua;
}


1;

