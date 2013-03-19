-module(full_ets_scan_test).

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

-export([assoc/0, bagger/0]).

assoc() ->
    Samples = 4000,
    Table = ets:new(no_bagger, [ set, private ]),
    ?TIMEON,
    populate(Table, Samples),
    ?TIMEOFF(execute),
    dump_table_row_count(Table),
    io:format("matching full key"),
    ?TIMEON,
    Match = ets:match(Table, {{4000,1}, '$1'}),
    Match1 = ets:match(Table, {{4000,20000}, '$1'}),
    Match2 = ets:match(Table, {{4000,50000}, '$1'}),
    Match6 = ets:match(Table, {{3999,2}, '$1'}),
    Match7 = ets:match(Table, {{3999,20001}, '$1'}),
    Match8 = ets:match(Table, {{3999,50001}, '$1'}),
    Match9 = ets:match(Table, {{3998,2}, '$1'}),
    Match10 = ets:match(Table, {{3998,20002}, '$1'}),
    Match11 = ets:match(Table, {{3998,50002}, '$1'}),
    ?TIMEOFF(execute),
    io:format("results ~p~n", [Match11]),
    io:format("matching partial key missing end"),
    ?TIMEON,
    Match3 = ets:match(Table, {{5,'$1'}}),
    Match4 = ets:match(Table, {{6,'$1'}}),
    Match5 = ets:match(Table, {{7,'$1'}}),
    ?TIMEOFF(execute),
    io:format("matching partial key missing start"),
    ?TIMEON,
    ets:match(Table, {{'$1',1}}),
    ets:match(Table, {{'$1',2}}),
    ets:match(Table, {{'$1',3}}),
    ?TIMEOFF(execute),
    ets:delete(Table),
    Match.

populate(Table, Key) ->
    populate(Table, Key, 1),
    populate(Table, Key, 20000),
    populate(Table, Key, 50000),
    populate(Table, Key, 100000).

populate(Table, Key, Index) when Key =:= 0 ->
    ok;
populate(Table, Key, Index) ->
    SearchIndex = {Key, Index},
    ets:insert(Table, {SearchIndex, 1}),
    populate(Table, Key-1, Index+1).

dump_table_row_count(Table) ->
    Data = ets:info(Table, size),
    io:format("rows ~p~n",[Data]).


bagger() ->
    Samples = 4000,
    Table = ets:new(bagger, [ bag, private ]),
    ?TIMEON,
    populate_bag(Table, Samples),
    ?TIMEOFF(execute),
    dump_table_row_count(Table),
    io:format("matching full key"),
    ?TIMEON,
    Match = ets:lookup(Table, 4000),
    Match1 = ets:lookup(Table, {3999,'$1'}),
    Match2 = ets:lookup(Table, {3998,'$1'}),
    Match3 = ets:lookup(Table, {20000, '$1'}),
    Match4 = ets:lookup(Table, {50000,'$1'}),
    Match5 = ets:lookup(Table, 100000),
    ?TIMEOFF(execute),
    io:format("results ~p ~p ~n", [Match, Match5]),
    ets:delete(Table),
    Match.

populate_bag(Table, Key) ->
    populate_bag(Table, Key, 1),
    populate_bag(Table, Key, 20000),
    populate_bag(Table, Key, 50000),
    populate_bag(Table, Key, 100000).

populate_bag(Table, Key, Index) when Key =:= 0 ->
    ok;
populate_bag(Table, Key, Index) ->
    ets:insert(Table, {Key, Index}),
    ets:insert(Table, {Index, Key}),
    populate(Table, Key-1, Index+1).

