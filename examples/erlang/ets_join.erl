-module(ets_join).
-export([do/0]).
-include_lib("stdlib/include/qlc.hrl").

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

do() ->
    Amount = 10000,
    Tab2KeyOffset = 100000,
    Tab3KeyOffset = 500000,
    Tab3ValueOffset = 1000000,
    Table1 = ets:new(tab1, [bag, protected, named_table]),
    Table2 = ets:new(tab2, [bag, protected, named_table]),
    Table3 = ets:new(tab3, [bag, protected, named_table]),

    io:format("~p ~p ~p~n", [Table1, Table2, Table3]),
    [
        ets:insert(tab1, {Key, Key + Tab2KeyOffset})
    ||
        Key <- lists:seq(0, Amount)
    ],

    [
        ets:insert(tab2, {Key + Tab2KeyOffset, Key + Tab3KeyOffset})
    ||
        Key <- lists:seq(0, Amount)
    ],

    [
        ets:insert(tab3, {Key+Tab3KeyOffset, Key + Tab3ValueOffset})
    ||
        Key <- lists:seq(0, Amount)
    ],
    get_key(1),
    Start = qlc:q([ 
                                    {Source, Destination} 
                               || 
                                    {Source, SubKey} <- ets:table(tab1), 
                                    {SKey, Destination} <- ets:table(tab2), 
                                    SubKey =:= SKey
                               ], [{join, 'merge'}, {'max_lookup', 'infinity'}]),

    Finish = qlc:q([ 
                                    {Source, Destination} 
                               || 
                                    {Source, SubKey} <- Start, 
                                    {Key, Destination} <- ets:table(tab3), 
                                    SubKey =:= Key 
                               ], [{join, 'lookup'}, {'max_lookup', 'infinity'}]),
    io:format("~p~n", [Finish]),
    ?TIMEON,
    Oh = qlc:e(Finish),
    ?TIMEOFF("qlc"),
    ?TIMEON,
    OhOh = get_all_keys(Amount - 1, []),
    ?TIMEOFF("walker"),
    io:format("~p ~p", [length(Oh), length(OhOh)]).


get_all_keys(-1, Accum) -> Accum;
get_all_keys(Number, Accum) ->
    get_all_keys(Number - 1, [get_key(Number)| Accum]).

get_key(Key) ->
    [{Key, Tab2Key}] = ets:lookup(tab1, Key),
    [{Tab2Key, Tab3Key}] = ets:lookup(tab2, Tab2Key),
    [{Tab3Key, Final}] = ets:lookup(tab3, Tab3Key),
    {Key, Final}.

