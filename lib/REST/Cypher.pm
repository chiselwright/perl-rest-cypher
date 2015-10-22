package REST::Cypher;

# ABSTRACT: Experimental client for using neo4j's REST/Cypher interface
# KEYWORDS: neo4j graph graphdb cypher REST

use strict;
use warnings;

use Moo;
use MooX::Types::MooseLike::Base qw/Bool/;
use MooseX::Params::Validate;

use REST::Cypher::Agent;

=head1 ATTRIBUTES

=head2 agent

=cut
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

=head2 server

=cut
has server => (
    is          => 'ro',
    required    => 1,
    default     => 'localhost',
);

=head2 server_port

=cut
has server_port => (
    is          => 'ro',
    required    => 1,
    default     => '7474',
);

=head2 rest_base_url

=cut
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

=head2 debug

=cut
has debug => (
    is      => 'rw',
    isa     => Bool,
    default => 0,
);

=head1 METHODS

=head2 query($self, %params)

Send a Cypher query to the server,

=cut
sub query {
    my ($self, %params) = validated_hash(
        \@_,
        query_string => { isa => 'Str' },
    );

    my $response = $self->agent->POST(
        query_string => $params{query_string}
    );
}

1;
=pod

=head1 DESCRIPTION

Interact with a neo4j Cypher API.

=head1 SYNOPSIS

    use Rest::Cypher::Agent;
    use Data::UUID;

    my $neo = REST::Cypher::Agent->new({
      base_url => 'http://example.com:7474',
    });

    my ($response, $nodeType);

    # let's create a GUID for a node
    my $guid = Data::UUID->new->to_string(Data::UUID->new->create);

    $nodeType = 'MyNodeType';
    $response = $neo->POST(
      query_string => "MERGE (a:${nodeType} {guid: {newGUID}}) RETURN a",
      query_params => {
        newGUID => $guid,
      }
    );

=head1 ACKNOWLEDGMENTS

This module was written to scratch an itch after using L<REST::Neo4p>; I liked
the L<REST::Neo4p::Query> and wanted to attempt to implement something that
felt like it was Cypher driven, and less about specific nodes and indexes.

I may be way off the mark, but this module is currently useful for throwing
hand-written Cypher at a neo4j server.

Over time it may even implement more interesting features.

=head1 SEE ALSO

=for :list
* L<REST::Cypher::Agent>
* L<neo4j|http://neo4j.org>
* L<REST::Neo4p>

=cut
__END__
# vim: ts=8 sts=4 et sw=4 sr sta
