#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use FindBin::libs;

use REST::Cypher::Agent;

my $rca;
my $response;

# missing argument to new()
dies_ok {
    $rca = REST::Cypher::Agent->new;
}
    "new() dies with missing required argument 'base_url'";

lives_ok {
    $rca = REST::Cypher::Agent->new(
        base_url    => 'http://fulcrum-archdev.dave:7474/', # XXX
    );
}
    'created new REST::Cypher::Agent object';

lives_ok {
    $response = $rca->GET(
        query_string => '/',
    );
}
    "successfully fetched '/'";

lives_ok {
    $response = $rca->POST(
        query_string => 'MATCH (p:SizeScheme) RETURN count(p)',
    );
}
    "successfully POSTed";

lives_ok {
    $response = $rca->POST(
        query_string => 'MATCH (p:Product {pid:334261})-[r:HAS_SIZE]-(:Size) DELETE r',
    );
}
    "POSTed a DELETE r query";

# can't use params with MATCH (apparently)
# we appear to still 'live', so we need to check the response for the error
lives_ok {
    $response = $rca->POST(
        query_string => 'MATCH (p:Product { props })-[r:HAS_SIZE]-(:Size) DELETE r',
        query_params => {
            props => {
                pid     => 334261,
            },
        },
    );
}
    "POSTed a failing MATCH+params query";

use JSON::Any;
my $j = JSON::Any->new;
my $response_from_json = $j->decode($response->content);
ok (
    exists $response_from_json->{message},
    'the response has a message'
);
is (
    $response_from_json->{exception},
    'SyntaxException',
    'response raised SyntaxException'
);




explain $response->content;

done_testing;
