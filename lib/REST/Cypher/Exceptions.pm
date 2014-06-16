package REST::Cypher::Exceptions;
use Moo;

{
    package REST::Cypher::Exceptions::TestException;
    use Moo; with 'Throwable';
}

{
    package REST::Cypher::Exceptions::InvalidJsonString;
    use Moo; with 'Throwable';
}

{
    package REST::Cypher::Exceptions::ConnectionError;
    use Moo; with 'Throwable';
}

1;
