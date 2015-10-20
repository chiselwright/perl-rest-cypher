package REST::Cypher::Exception {
    use strict;
    use warnings;

    use Moo;
    with 'Throwable';

    use overload
        q{""}    => 'as_string',
        fallback => 1;

    sub as_string {
        my ($self) = @_;
        return $self->message;
    }
}

package REST::Cypher::Exception::Response {
    use Moo;
    extends 'REST::Cypher::Exception';

    has response => ( is => 'ro', required => 1 );
    has error    => ( is => 'ro', required => 1, lazy => 1, builder => '_build_error' );

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

    sub message {
        return $_[0]->error->{message};
    }
}

1;
