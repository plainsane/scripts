-module(dict_speed_test).


-export([do/0]).

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

do() ->
    Total = 5000,
    Dict = load_dict(Total),
    ?TIMEON,
    search_dict_safe(Total, Dict),
    ?TIMEOFF(search_dict_safe),
    ?TIMEON,
    search_dict(Total, Dict),
    ?TIMEOFF(search_dict),
    ?TIMEON,
    length_list(Total, [1,2,3,4,5,6]),
    ?TIMEOFF(length_list),
    print_dict(Dict),
    ok.

load_dict(Number) ->
    add_key(Number, dict:new()).    

add_key(0, Dict) -> Dict;
add_key(Number, Dict) ->
    NewDict = dict:store(Number, Number, Dict),
    add_key(Number - 1, NewDict).

search_dict_safe(0, Dict) -> Dict;
search_dict_safe(Number, Dict) ->
    Var = case dict:is_key(Number, Dict) of
        true -> dict:fetch(Number, Dict);
        false -> 0
    end,
    search_dict_safe(Var - 1, Dict).

search_dict(0, Dict) -> Dict;
search_dict(Number, Dict) ->
    Var = dict:fetch(Number, Dict),
    search_dict_safe(Var - 1, Dict).

length_list(0, List) -> ok;
length_list(Number, List) ->
    length(List),
    length_list(Number - 1, List).

print_dict(Dict) ->
    [
        io:format("~p:~p", [Key, Value]) 
    ||
        {Key, Value} <- Dict
    ].
