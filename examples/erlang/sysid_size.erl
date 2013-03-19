-module(sysid_size).

-export([do/1]).

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

populate_table(_, 0) -> ok;
populate_table(Table, Count) ->
    SysId1 = <<0:32,1:16,1:16, Count:64>>,
    %SysId2 = <<0:32,2:16,2:16, Count:64>>,
    ets:insert(Table, {SysId1, SysId1}),
    populate_table(Table, Count - 1).


populate_dict(Dict, 0) -> Dict;
populate_dict(Dict, Count) ->
    SysId1 = <<0:32,1:16,1:16, Count:64>>,
    %SysId2 = <<0:32,2:16,2:16, Count:64>>,
    populate_dict(dict:store(SysId1, SysId1, Dict), Count - 1).

do(Type) ->
    do(Type, 100000).

do(ets, Count) ->
    Table = ets:new(source, [ set, protected, named_table ]),
    populate_table(Table, Count),
    erlang:garbage_collect(self()),
    Size = ets:info(source, size),
    Memory = ets:info(source, memory) * 8,
    ets:delete(Table),
    {Size, Memory, Memory/Size};

do(dict, Count) ->
    {_, StartMem} = process_info(self(), memory),
    Dict = populate_dict(dict:new(), Count),
    erlang:garbage_collect(self()),
    TotalRecs = dict:size(Dict),
    {_, EndMem} = process_info(self(), memory),
    TotalMem = EndMem - StartMem,
    {TotalRecs, TotalMem, TotalMem/TotalRecs}.

