-module(stack_overflow).

-export([do/0]).

do() ->
    recurse(5).

recurse(0) ->
    throw("oh shit");
recurse(Num) ->
    try
        io:format("ooh"),
        recurse(Num - 1)
    catch
        _ ->
            io:format("got some shit ~p ~n", [erlang:get_stacktrace()]),
            throw("oh shit")
    end.

