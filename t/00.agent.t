#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use FindBin::libs;

use REST::Cypher::Agent;
use HTTP::Status qw(:constants);

my $rca;
my $response;

if (not defined $ENV{PERL_CYPHER_NEO4J_ADDRESS}) {
    plan skip_all => 'PERL_CYPHER_NEO4J_ADDRESS needs a value';
}

# missing argument to new()
dies_ok {
    $rca = REST::Cypher::Agent->new;
}
    "new() dies with missing required argument 'base_url'";

lives_ok {
    $rca = REST::Cypher::Agent->new(
        base_url    => $ENV{PERL_CYPHER_NEO4J_ADDRESS},
    );
}
    'created new REST::Cypher::Agent object';

lives_ok {
    $response = $rca->GET(
        query_string => '',
    );
}
    "successfully fetched '/'";

# we're expecting to use a server that requires auth, so we should get a 401
# for the GET-/ request
is($response->code, HTTP_UNAUTHORIZED, "GET / returns HTTP_UNAUTHORIZED");

lives_ok {
    $response = $rca->POST(
        query_string => 'MATCH (p:SizeScheme) RETURN count(p)',
    );
}
    "successfully POSTed";
    explain $response;

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
