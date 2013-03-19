-module(walker).

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

-export([walk/0]).

walk() ->
    Samples = 72000,
    Table = ets:new(no_bagger, [ set, private ]),
    ?TIMEON,
    populate(Table, Samples, 1),
    ?TIMEOFF(walk),
    ?TIMEON,
    Count = walk(Table),
    ?TIMEOFF(walk),
    io:format("walked ~p times~n", [Count]),
    ?TIMEON,
    Iterate = iterate(Table),
    ?TIMEOFF(walk),
    io:format("iterate ~p times~n", [Iterate]),
    'woot'.

walk(Table) ->
    walk(Table, ets:first(Table), 0).

walk(_, '$end_of_table', Count)->
    Count;
walk(Table, Key, Count) ->
    ets:match(Table, Key),
    walk(Table, ets:next(Table, Key), Count + 1).

populate( _Table, Key, _Value) when Key =:= 0 ->
    ok;
populate(Table, Key, Value) ->
    ets:insert(Table, {Key, Value}), 
    populate(Table, Key-1, Value + 1).


iterate(Table) ->
    iterate(ets:match(Table, {'_', '$1'}), 0).

iterate([], Count) ->
    Count;
iterate([Head|Rest], Count) ->
    iterate(Rest, Count + 1).
