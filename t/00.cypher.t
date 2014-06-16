#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use FindBin::libs;

use REST::Cypher;

my $rc;
lives_ok {
    $rc = REST::Cypher->new;
} 'created new REST::Cypher instance';

is(
    $rc->server,
    'localhost',
    "'server' defaults to 'localhost'"
);

is(
    $rc->server_port,
    7474,
    "'server_port' defaults to '7474'"
);

is(
    $rc->rest_base_url,
    'http://localhost:7474',
    "'rest_base_url' default value is 'http://localhost:7474'",
);

# this should (currently) live, as the response succeeds even though we can't
# actually reach the server
lives_ok {
    $rc->query(
        query_string => 'MATCH (n:Foo) RETURN count(n)',
    );
} '->query call succeeds';


# XXX archdev
$rc = REST::Cypher->new( server => 'fulcrum-archdev.dave' );
is(
    $rc->rest_base_url,
    'http://fulcrum-archdev.dave:7474',
    "'rest_base_url' default value is 'http://fulcrum-archdev.dave:7474'",
);
lives_ok {
    $rc->query(
        query_string => 'MATCH (n:Foo) RETURN count(n)',
    );
} '->query call succeeds';


done_testing;
