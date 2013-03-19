-module(ets_select).

-export([do/0]).

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

do() ->
    Count = 0,
    Table = ets:new(source, [ set, protected, named_table ]),
    ?TIMEON,
    populate_table(Table, Count),
    ?TIMEOFF("populate"),
    ?TIMEON,
    select_records(Table, Count, 1),
    ?TIMEOFF("select"),
    ?TIMEON,
    ets:select_count(Table, [{{ {'$1', 2},'$2'},[ { '=/=', '$2', 0} ],['$1']}]),
    ?TIMEOFF("match"),
    ets:insert(source, [{{{1,25,1}, 1}, 5}, {{{1,25,2}, 1}, 4}, {{{1,5,1}, 2}, 5}]),
    ets:select(source, [{
                { 
                    {{'$4','$1','$5'}, '$2'},'$3'
                },[
                    {'andalso', 
                        {'andalso', 
                            {'=:=', '$1', 5},
                            {'=:=', '$2', 2}
                        },
                        {'=:=', '$3', 5}
                    }
                  ],
                [[{'$4','$1','$5'}, '$2']]}]).
    
    %timer:tc(ets, select, [prop_table, [{{ {'$1', '$2'},'$3'},[ {'andalso', {'orelse', {'=:=', '$2', -27}, {'=:=', '$2', -7}}, {'orelse', { '=:=', '$1',<<0,0,0,0,0,1,0,25,0,0,0,0,0,0,3,83>>}, { '=:=', '$1', <<0,0,0,0,0,1,0,5,0,0,0,0,0,0,17,122>>} }, {'>=', '$3', 1} } ],[['$1', '$2']]}]]).

populate_table(_, 0) -> ok;
populate_table(Table, Count) ->
    ets:insert(Table, {{Count,2}, Count}),
    populate_table(Table, Count - 1).

clone_table(Source, Destination) ->
        ets:insert(Destination, ets:tab2list(Source)).

select_records(Table, 0, Start) -> ok;
select_records(Table, Amount, Start) ->
    case ets:select_count(Table, [{{ {Start, 2},'$1'},[ { '=:=', '$1', Start} ],['true']}]) of
        0 -> [];
        _ -> [Start]
    end,
    select_records(Table, Amount - 1, Start + 1).

