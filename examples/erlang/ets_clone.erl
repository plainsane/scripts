-module(ets_clone).

-export([do/0]).

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

do() ->
    Count = 50000,
    Table = ets:new(source, [ set, protected, named_table ]),
    ?TIMEON,
    populate_table(Table, Count),
    ?TIMEOFF("populate"),
    CloneTable = ets:new(clone, [ set, protected, named_table ]),
    ?TIMEON,
    clone_table(Table, CloneTable),
    ?TIMEOFF("clone"),
    ets:delete(Table),
    ets:delete(CloneTable).
    
populate_table(_, 0) -> ok;
populate_table(Table, Count) ->
    ets:insert(Table, {{Count,2}, <<"ohhh long string">>}),
    populate_table(Table, Count - 1).

clone_table(Source, Destination) ->
    io:format("da rows ~p~n", [ets:select(Source, [{'_',[ ],['$_']}], 5)]),
    ?TIMEON,
    A = ets:select(Source, [{'_',[ ],['$_']}]),
    ?TIMEOFF("select"),
    ?TIMEON,
    B = [ {{Z,X},Y} || [Z,X,Y] <- ets:match(Source, '$1')],
    ?TIMEOFF("match"),
    ?TIMEON,
    C = ets:tab2list(Source),
    ?TIMEOFF("list"),
    ets:insert(Destination, ets:tab2list(Source)).
