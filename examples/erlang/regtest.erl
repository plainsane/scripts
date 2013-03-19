-module(regtest).
-export([do/0]).

p(Value) ->
    io:format("~p~n", [Value]).

do() ->
    {ok, Spec} = re:compile( <<"(^|,)(\\Q1.1.1.1\\E)($|,)">> ),
    p(re:run( <<"1.1.1.1">>, Spec, [{capture,none}] )),
    p(re:run( <<"1a1a1a1">>, Spec, [{capture,none}] )),
    p(re:run( <<"1.1.1.1,23.23.23.23">>, Spec, [{capture,none}] )),
    p(re:run( <<"1a1a1a1,23.23.23.23">>, Spec, [{capture,none}] )),
    p(re:run( <<"23.23.23.23,1.1.1.1">>, Spec, [{capture,none}] )),
    p(re:run( <<"23.23.23.23,11.1.1.1">>, Spec, [{capture,none}] )).
