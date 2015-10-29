package REST::Cypher::Exception;
# ABSTRACT base class for exception handling

use strict;
use warnings;

use Moo;
with 'Throwable';

use overload
    q{""}    => 'as_string',
    fallback => 1;

=pod

=head2 as_string

This method in L<REST::Cypher::Exception> allows easy stringification of
thrown exceptions.

It returns the current value of I<message>.

=cut
sub as_string {
    my ($self) = @_;
    return $self->message;
}


1;
