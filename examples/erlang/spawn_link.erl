-module(spawn_link).
-export([do/0, do_some_shit/2]).
-include_lib("stdlib/include/qlc.hrl").

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

do() ->
    process_flag(trap_exit, true),
    Proc = erlang:spawn_link(?MODULE, do_some_shit, [self(), {a,b,c}]),
    io:format("~p, ~p", [self(), Proc]),
    get_some_shit(2).

get_some_shit(0) -> ok;
get_some_shit(Count) ->
    receive
        {'EXIT', FromPid, Reason} ->
            io:format("EXIT ~p", [Reason]),
            get_some_shit(Count-1);
        Unknown ->
            io:format("WHAT THE FUCK ~p", [Unknown]),
            get_some_shit(Count - 1)
    end.

do_some_shit(Parent, Args) ->
    Parent ! {1,2,3}.
