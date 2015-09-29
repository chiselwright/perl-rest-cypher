package REST::Cypher::Agent;

use Moo;
use MooX::Types::MooseLike::Base qw/Bool/;
use MooseX::Params::Validate;

use LWP::UserAgent;

=head1 ATTRIBUTES

=head2 base_url

=cut
has base_url => (
    is          => 'rw',
    required    => 1,
    writer      => '_base_url',
);

=head2 cypher_url

=cut
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

=head2 agent_string

=cut
has agent_string => (
    is      => 'ro',
    default => sub { q[REST::Cypher::Agent/0.0.0] },
);

=head2 agent

=cut
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

=head2 auth_token

=cut
has auth_token => (
    is      => 'ro',
    lazy    => 1,
    default => 'bmVvNGo6ZHJhZzk5',
);

=head2 last_response

=cut
has last_response => (
    is      => 'rw',
);

=head2 debug

=cut
has debug => (
    is      => 'rw',
    isa     => Bool,
    default => 0,
);

=head1 METHODS

=cut

=head2 GET

=cut
sub GET {
    my ($self, %params) = validated_hash(
        \@_,
        query_string => { isa => 'Str' },
    );

    my $string =
        sprintf(
            '%s/db/data%s',
            $self->base_url,
            $params{query_string},
        );

    $self->last_response(
        $self->agent->get($string)
    );
}


=head2 POST

=cut
sub POST {
    my ($self, %params) = validated_hash(
        \@_,
        query_string    => { isa => 'Str',      optional => 0, },
        query_params    => { isa => 'HashRef',  optional => 1, },
    );
    
    use JSON::Any;
    my $json = JSON::Any->objToJson(
        {
            query   => $params{query_string},
            params  => $params{query_params},
        }
    );

    if ($self->debug) {
        my $tmp =  $params{query_string};
           $tmp =~ s{\s+}{ }g;
        warn "[POST] $tmp\n";
    }

$DB::single=1;
    $self->last_response(
        $self->agent->post(
            $self->cypher_url,
            Content => $json,
            'Content-Type' => 'application/json',
            'Authorization' => "Basic " . $self->auth_token,
        )
    );
}


1;
