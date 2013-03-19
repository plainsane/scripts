-module(iflistcomp).

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

-export([do/0]).

do() ->
    Data = [{1,2}, {1,2,3}],
    [ 
        {One, Two, Three} || Element <- Data, {One, Two, Three} <- case Element of
                                            {_, _, _} -> 
                                                    [Element];
                                            {E1, E2} -> 
                                                    [{E1, E2, 999}]
                                            end
    ].
