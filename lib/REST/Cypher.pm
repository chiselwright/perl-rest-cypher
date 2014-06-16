package REST::Cypher;
use strict;
use warnings;

use Moo;
use MooX::Types::MooseLike::Base qw/Bool/;
use MooseX::Params::Validate;
use Try::Tiny;

use REST::Cypher::Exceptions;
use REST::Cypher::Agent;

has agent => (
    is      => 'rw',
    lazy    => 1,
    writer  => '_set_agent',

    default => sub {
        REST::Cypher::Agent->new(
            base_url => $_[0]->rest_base_url,
            debug    => $_[0]->debug,
        );
    },
);

has server => (
    is          => 'ro',
    required    => 1,
    default     => 'localhost',
);

has server_port => (
    is          => 'ro',
    required    => 1,
    default     => '7474',
);

has rest_base_url => (
    is          => 'ro',
    lazy        => 1,
    default     => sub {
        sprintf(
            'http://%s:%d',
            $_[0]->server,
            $_[0]->server_port,
        );
    },
);

has debug => (
    is      => 'rw',
    isa     => Bool,
    default => 0,
);

sub query {
    my ($self, %params) = validated_hash(
        \@_,
        query_string => { isa => 'Str' },
    );

    my $exception;
    my $response;
    try {
        my $response = $self->agent->POST(
            query_string => $params{query_string}
        );
    }
    catch {
        $exception = $_;
    };
    if ($exception) {
        if (!blessed $exception) {
            die "unhandled exception: $exception";
        }

        if ($exception->isa('REST::Cypher::Exceptions::TestException')) {
            die "why are you using TestException?";
        }

        die $exception;
        }
    }
}

1;
# ABSTRACT: REST::Cypher needs a more meaningful abstract
__END__
# vim: ts=8 sts=4 et sw=4 sr sta
