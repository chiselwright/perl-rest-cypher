package REST::Cypher::Agent;

# ABSTRACT: Experimental client for using neo4j's REST/Cypher interface
# KEYWORDS: neo4j graph graphdb cypher REST

use Moo;

use REST::Cypher::Exception::Response;

use MooX::Types::MooseLike::Base qw/Bool/;
use MooseX::Params::Validate;

use JSON::Any;
use LWP::UserAgent;

=head1 ATTRIBUTES

=head2 base_url

This is the full URL value of the neo4j server to connect to.

    base_url => http://my.neo4j.example.com:7474

It is a B<required> attribute, with no default value.

=cut
has base_url => (
    is          => 'rw',
    required    => 1,
    writer      => '_base_url',
);

=head2 cypher_url

This is the URL used to connect to the Cypher endpoint(s).

It is a B<derived> value, based on C<base_url>

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

This attribute provides the value for the User Agent string when making API calls.

This attribute has a B<default value> of C<REST::Cypher::Agent/0.0.0>, but may be overridden.

=cut
has agent_string => (
    is      => 'ro',
    default => sub { q[REST::Cypher::Agent/0.0.0] },
);

=head2 agent

This attribute holds the agent object, used for making the HTTP calls to the API endpoint.

The default value is an instance of L<LWP::UserAgent>. You may override this. I<At your own risk>.

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

neo4j allows authentication to be enabled for connections to the database.
For I<recent> versions this is enabled by default.

The auth-token value is 'I<a base64 encoded string of "username:password">'

The B<default value> is set to the equivalent of C<encode_base64('neo4j:neo4j')>.

=cut
has auth_token => (
    is      => 'rw',
    lazy    => 1,
    default => 'bmVvNGo6bmVvNGo=',
);

=head2 last_response

This attribute stores the response object from the most recent call to the API.
See L<HTTP::Response> for a description of the interface it provides.

=cut
has last_response => (
    is      => 'rw',
);

=head2 debug

This I<boolean> attribute enables debugging output for the class.

=cut
has debug => (
    is      => 'rw',
    isa     => Bool,
    default => 0,
);

=head1 METHODS

=cut

=head2 GET

This method provides low-level access to C<LWP::UserAgent->get()>.

It takes care of constructing the URL, using the provided query parameters.

The method returns the response object, after storing it in C<last_response>.

    # (just) GET the base URL
    $response = $cypher_agent->GET({query_string => '' });


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

    $self->last_response(
        $self->agent->post(
            $self->cypher_url,
            Content => $json,
            'Content-Type' => 'application/json',
            'Authorization' => "Basic " . $self->auth_token,
        )
    );

    if (! $self->last_response->is_success) {
        REST::Cypher::Exception::Response->throw({
            response => $self->last_response,
        });
    }
}

1;

=pod

=head1 DESCRIPTION

Interact with a neo4j Cypher API.

=head1 GENERATING AUTH TOKEN

You can generate your own C<auth_token> value using L<MIME::Base64>

    perl -MMIME::Base64 -e "warn encode_base64('neo4j:neo4j');"

=head1 SEE ALSO

=for :list
* L<neo4j|http://neo4j.org>
* L<REST::Neo4p>

=cut

