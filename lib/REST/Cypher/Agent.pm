package REST::Cypher::Agent;
use Moo;
use MooX::Types::MooseLike::Base qw/Bool/;
use MooseX::Params::Validate;

use JSON::Any;
use LWP::UserAgent;
use Try::Tiny;

use REST::Cypher::Exceptions;

has base_url => (
    is          => 'rw',
    required    => 1,
    writer      => '_base_url',
);

has cypher_url => (
    is          => 'ro',
    lazy        => 1,
    default => sub {
        my $self = shift;

        my $base = $self->base_url;
        if($base =~ s{/$}{}) {
            $self->_base_url( $base );
            warn $self->base_url;
        }

        sprintf(
            '%s/db/data/cypher',
            $self->base_url,
        )
    }
);

has agent_string => (
    is      => 'ro',
    default => sub { q[REST::Cypher::Agent/0.0.0] },
);

has agent => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        LWP::UserAgent->new(
            agent               => $self->agent_string,
            protocols_allowed   => [ 'http', 'https'],
            default_header      => [ Accept => 'application/json' ],
        );
    },
);

has last_response => (
    is      => 'rw',
);

has debug => (
    is      => 'rw',
    isa     => Bool,
    default => 0,
);

sub GET {
    my ($self, %params) = validated_hash(
        \@_,
        query_string => { isa => 'Str' },
    );

    my $string =
        sprintf(
            '%sdb/data%s',
            $self->base_url,
            $params{query_string},
        );

    $self->last_response(
        $self->agent->get($string)
    );
}


sub POST {
    my ($self, %params) = validated_hash(
        \@_,
        query_string    => { isa => 'Str',      optional => 0, },
        query_params    => { isa => 'HashRef',  optional => 1, },
    );

    my ($exception, $json);

    try {
        $json = JSON::Any->objToJson(
            {
                query   => $params{query_string},
                params  => $params{query_params},
            }
        );
    }
    catch {
        $exception = $_;
        REST::Cypher::Exceptions::InvalidJsonString->throw;
    };

    if ($self->debug) {
        my $tmp =  $params{query_string};
           $tmp =~ s{\s+}{ }g;
        warn "[POST] $tmp\n";
    }

    $self->last_response(
        $self->agent->post(
            $self->cypher_url,
            Content => $json,
            'Content-Type' => 'application/json',
        )
    );
}


1;
