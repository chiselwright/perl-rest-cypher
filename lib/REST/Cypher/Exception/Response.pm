package REST::Cypher::Exception::Response;
# ABSTRACT handle REST API response exceptions

use Moo;
extends 'REST::Cypher::Exception';

=head1 CLASS ATTRIBUTES

=head2 response

Used to store the failed response.

=cut
has response => ( is => 'ro', required => 1 );

=head2 error

Used to store the formatted data structure of error information from the
failed response.

=cut
has error    => ( is => 'ro', required => 1, lazy => 1, builder => '_build_error' );

=head1 METHODS

=head2 message

The value to return if we get strigified.

=cut
sub message {
    # TODO return something more helpful (to our end user)
    return $_[0]->error->{message};
}


=head1 PRIVATE METHODS

=head2 BUILD

Make really certain that we have instantiated the C<error> attribute.

=cut
sub BUILD {
    my $self = shift;

    # force ->error to be built
    warn "failed a lazy build"
        unless $self->error;
}

sub _build_error {
    my $self = shift;
    $self->{error} = {
        code        => $self->response->code,
        message     => $self->response->message,
        as_string   => $self->response->as_string,
    };
}

1;
