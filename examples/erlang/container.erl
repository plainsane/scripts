-module(container).

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

-export([execute/0, bag/0, stupid/0, queue/0]).

-record(woot, {sum, count}).

execute() ->
    Samples = 3000,
    Table = ets:new(no_bagger, [ set, private ]),
    ?TIMEON,
    populate(Table, Samples),
    ?TIMEOFF(execute),
    ?TIMEON,
    find(Table, Samples),
    ?TIMEOFF(execute),
    ?TIMEON,
    update(Table, Samples),
    ?TIMEOFF(execute),
    dump_table_row_count(Table),
    ?TIMEON,
    ets:match_delete(Table, {{4,'_','_'}, '$1'}),
    ?TIMEOFF(execute),
    dump_table_row_count(Table),
    ?TIMEON,
    ets:delete(Table, {1,1,1}),
    ?TIMEOFF(execute),
    dump_table_row_count(Table),
    ?TIMEON,
    Match = ets:match(Table, {{5,1,1}, '$1'}),
    Match1 = ets:match(Table, {{5,2,1}, '$1'}),
    Match2 = ets:match(Table, {{5,3,1}, '$1'}),
    ?TIMEOFF(execute),
    ?TIMEON,
    Match3 = ets:match(Table, {{5,1,'_'}, '$1'}),
    Match4 = ets:match(Table, {{5,2,'_'}, '$1'}),
    Match5 = ets:match(Table, {{5,3,'_'}, '$1'}),
    ?TIMEOFF(execute),
    ets:delete(Table),
    Match.

walk() ->
    Samples = 3000,
    Table = ets:new(no_bagger, [ set, private ]),
    ?TIMEON,
    populate(Table, Samples),
    ?TIMEOFF(walk),
    ?TIMEON,
    walk(Table, Samples),
    ?TIMEOFF(walk),
    'woot'.

walk(Table) ->
    find(Table, ets:first(Table)),

walk(Table, '$end_of_table')->
    ok;
walk(Table, Key) ->
    A = ets:match(Table, ets:next(Table, Key)).

populate(Table, Key) ->
    populate(Table, Key, 1),
    populate(Table, Key, 2),
    populate(Table, Key, 3).

populate(Table, Key, Index) when Key =:= 0 ->
    ok;
populate(Table, Key, Index) ->
    populate_item(Table, Key, Index, 8),
    populate(Table, Key-1, Index).

populate_item(Table, Key, Index, Count) when Count =:= 0 ->
    ok;
populate_item(Table, Key, Index, Count) ->
    SearchIndex = {Key, Index, Count},
    ets:insert(Table, {SearchIndex, #woot{sum = Count, count=Count}}),
    populate_item(Table, Key, Index, Count - 1).

find(Table, Key) ->
    find(Table, Key, 1),
    find(Table, Key, 2),
    find(Table, Key, 3).

find(Table, Key, Index) when Key =:= 0 ->
    ok;
find(Table, Key, Index) ->
    find_item(Table, Key, Index, 8),
    find(Table, Key - 1, Index).

find_item(Table, Key, Index, Count) when Count =:= 0 ->
    ok;
find_item(Table, Key, Index, Count) ->
    SearchIndex = {Key, Index, Count},
    case ets:match(Table, {SearchIndex, '$1'}) of
        [[Data]|_] ->
            ok;
        [] ->
            io:format("couldnt find  the entry on ~p try ~n", [Count]), 
            ok
    end,
    find_item(Table, Key, Index, Count - 1).

update(Table, Key) ->
    update(Table, Key, 1),
    update(Table, Key, 2),
    update(Table, Key, 3).

update(Table, Key, Index) when Key =:= 0 ->
    ok;
update(Table, Key, Index) ->
    update_item(Table, Key, Index, 8),
    update(Table, Key - 1, Index).

update_item(Table, Key, Index, Count) when Count =:= 0 ->
    ok;
update_item(Table, Key, Index, Count) ->
    SearchIndex = {Key, Index, Count},
    case ets:match(Table, {SearchIndex, '$1'}) of 
        [[#woot{}]|_]->
            ets:insert(Table, {SearchIndex, #woot{sum=Count + 1, count=Count + 1}});
        [] ->
            io:format("couldnt find  the entry on ~p try ~n", [Count]), 
            ok
    end,
    update_item(Table, Key, Index, Count - 1).

dump_table_row_count(Table) ->
    Data = ets:info(Table, size),
    io:format("rows ~p~n",[Data]).

bag() ->
    Samples = 3000,
    Table = ets:new(bagger, [ bag, private ]),
    ?TIMEON,
    ?TIMEON,
    populate_bag(Table, Samples),
    ?TIMEOFF(bag),
    ?TIMEON,
    many_find_bag(Table, Samples, 4),
    ?TIMEOFF(bag),
    ?TIMEON,
    many_update_bag(Table, Samples, 4),
    ?TIMEOFF(bag),
    dump_table_row_count(Table),
    ?TIMEON,
    ets:match_delete(Table, {{4,'_'}, '$1'}),
    ?TIMEOFF(bag),
    dump_table_row_count(Table),
    ?TIMEON,
    ets:match_delete(Table, {{1,1}, {1,'$1'}}),
    ?TIMEOFF(bag),
    dump_table_row_count(Table),
    ?TIMEON,
    Match = ets:match(Table, {{2,1}, {'$1','$2'}}),
    Match1 = ets:match(Table, {{2,2}, {'$1','$2'}}),
    Match2 = ets:match(Table, {{2,3}, {'$1','$2'}}),
    ?TIMEOFF(bag),
    ?TIMEOFF(bag),
    ets:delete(Table),
    {Match, Match1, Match2}.

populate_bag(Table, Key) ->
    populate_bag(Table, Key, 1),
    populate_bag(Table, Key, 2),
    populate_bag(Table, Key, 3).

populate_bag(Table, Key, Index) when Key =:= 0 ->
    ok;
populate_bag(Table, Key, Index) ->
    populate_bag_item(Table, Key, Index, 8),
    populate_bag(Table, Key - 1, Index).

populate_bag_item(Table, Key, Item, Count) when Count =:= 0 ->
    ok;
populate_bag_item(Table, Key, Index, Count) ->
    ets:insert(Table, { {Key, Index}, {Count, #woot{sum = Key, count=0}}}),
    populate_bag_item(Table, Key, Index, Count - 1).

many_find_bag(Table, Key, Count) when Count =:= 0->
    ok;
many_find_bag(Table, Key, Count) ->
    find_bag(Table,Key),
    many_find_bag(Table, Key, Count - 1).

find_bag(Table, Key) ->
    find_bag(Table, Key, 1),
    find_bag(Table, Key, 2),
    find_bag(Table, Key, 3).

find_bag(Table, Key, Index) when Key =:= 0 ->
    ok;
find_bag(Table, Key, Index) ->
    find_bag_item(Table, Key, Index, 8),
    find_bag(Table, Key - 1, Index).

find_bag_item(Table, Key, Index, Count) when Count =:= 0 ->
    ok;
find_bag_item(Table, Key, Index, Count) ->
    case ets:match(Table, {{Key, Index}, {Count, '$1'}}) of
        [[Data]|_] ->
            ok;
        [] ->
            io:format("couldnt find  the entry on ~p try ~n", [Count]), 
            ok
    end,
    find_bag_item(Table, Key, Index, Count - 1).

many_update_bag(Table, Key, Count) when Count =:= 0 ->
    ok;
many_update_bag(Table, Key, Count) ->
    update_bag(Table, Key),
    many_update_bag(Table, Key, Count - 1).

update_bag(Table, Key) ->
    update_bag(Table, Key, 1),
    update_bag(Table, Key, 2),
    update_bag(Table, Key, 3).

update_bag(Table, Key, Index) when Key =:= 0 ->
    ok;
update_bag(Table, Key, Index) ->
    update_bag_item(Table, Key, Index, 8),
    update_bag(Table, Key-1, Index).

update_bag_item(Table, Key, Index, Count) when Count =:= 0 ->
    ok;
update_bag_item(Table, Key, Index, Count) ->
    SearchIndex = {Key, Index},
    case ets:match(Table, {SearchIndex, {Count, '$1'}}) of 
        [[#woot{}]|_]->
            ets:insert(Table, { {Key, Index}, {Count, #woot{sum = Key, count=Index * Count}}});
        [] ->
            io:format("couldnt find  the entry on ~p try ~n", [Count]), 
            ok
    end,
    update_bag_item(Table, Key, Index, Count - 1).

stupid() ->
    Table = ets:new(bagger, [ bag, private ]),
    Key = {1, 1},
    ets:insert(Table, { Key, {1, 1}}),
    ets:insert(Table, { Key, {1, 2}}),
    dump_table_row_count(Table),

    ets:insert(Table, { Key, 2, 1}),
    ets:insert(Table, { Key, 2, 2}),
    dump_table_row_count(Table),
    ets:insert(Table, { Key, a, 1}),
    ets:insert(Table, { Key, a, 2}),

    dump_table_row_count(Table),
    ets:insert(Table, { Key, {a, 1}}),
    ets:insert(Table, { Key, {a, 2}}),
    dump_table_row_count(Table),

    ets:delete(Table).

queue() ->
    ?TIMEON,
    Q = queue:new(),
    Q1 = queue:in({1,2,3}, Q),
    Q2 = queue:in({1,2,3}, Q1),
    Q3 = queue:in({1,2,3}, Q2),
    Q4 = queue:in({1,2,3}, Q3),
    Q5 = queue:in({1,2,3}, Q4),
    Q6 = queue:in({1,2,3}, Q5),
    Q7 = queue:in({1,2,3}, Q6),
    Q8 = queue:in({1,2,3}, Q7),
    rip_queue(Q8),
    ?TIMEOFF(queue).

rip_queue(Q) ->
    rip_queue(Q, 148 * 3000 * 3).

rip_queue(Q, Count) when Count =:= 0 ->
    ok;

rip_queue(Q, Count) ->
    {{value, Item}, NewQueue} = queue:out_r(Q),
    rip_queue(queue:in({1,2,3}, NewQueue), Count - 1).

