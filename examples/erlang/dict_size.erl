-module(dict_size).
-compile(export_all).

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

-record('fun.full.object',              { sysid, properties, associations = [] } ).
-define(BATCHSIZE, 100000).
-define(METRIC_TYPE, 37 ).
-define(METRIC_KEY_PROP, -2 ).
-define(METRIC_KEY_ID_PROP, -13 ).
-define(METRIC_VALUE_TYPE, 38 ).
-define(METRIC_VAL_SYSID, 0 ).
-define(METRIC_VAL_METRIC_SYSID, -1 ).
-define(METRIC_VAL_PROP, -2 ).
-define(METRIC_VAL_START_PROP, -3 ).
-define(METRIC_VAL_KEY_PROP, -4 ).
-define(METRIC_VAL_EXISTS, -5 ).
-define(METRIC_VAL_ENTITIY_SYSID, -6 ).
-define(METRIC_VAL_TYPE_PROP, -7 ).
-define(METRIC_VAL_ENTITY_TYPE_ID, -8 ).
-define(METRIC_VAL_KEY_ID, -9 ).
-define(Entity, <<0,0,0,0,0,1,0,5,0,0,0,0,0,0,0,1>>).

get_mvs(_Creator, 0, Accum) -> Accum;
get_mvs(Creator, Amount, Accum) ->
    NewAccum = [Creator(?Entity, 10000, 12, 42)| Accum], 
    get_mvs(Creator, Amount - 1, NewAccum).

do(dict) ->
    erlang:garbage_collect(self()),
    {memory, StartSize} = erlang:process_info(self(), memory),
    DictBased = get_mvs(fun create_mv_dict/4, ?BATCHSIZE, []),
    erlang:garbage_collect(self()),
    {memory, EndSize} = erlang:process_info(self(), memory),
    io:format("Dict based: ~p~n", [EndSize - StartSize]),
    ?TIMEON,
    search(fun search_dict/1, DictBased),
    ?TIMEOFF("Dict");

do(orddict) ->
    erlang:garbage_collect(self()),
    {memory, StartSize} = erlang:process_info(self(), memory),
    OrddictBased = get_mvs(fun create_mv_orddict/4, ?BATCHSIZE, []),
    erlang:garbage_collect(self()),
    {memory, EndSize} = erlang:process_info(self(), memory),
    io:format("Orddict based: ~p~n", [EndSize - StartSize]),
    ?TIMEON,
    search(fun search_orddict/1,OrddictBased),
    ?TIMEOFF("Orddict");

do(gbdict) ->
    erlang:garbage_collect(self()),
    {memory, StartSize} = erlang:process_info(self(), memory),
    OrddictBased = get_mvs(fun create_mv_gbdict/4, ?BATCHSIZE, []),
    erlang:garbage_collect(self()),
    {memory, EndSize} = erlang:process_info(self(), memory),
    io:format("gbdict based: ~p~n", [EndSize - StartSize]),
    ?TIMEON,
    search(fun search_orddict/1,OrddictBased),
    ?TIMEOFF("gbdict");

do(list) ->
    erlang:garbage_collect(self()),
    {memory, StartSize} = erlang:process_info(self(), memory),
    ListBased = get_mvs(fun create_mv_list/4, ?BATCHSIZE, []),
    erlang:garbage_collect(self()),
    {memory, EndSize} = erlang:process_info(self(), memory),
    io:format("List based: ~p~n", [EndSize - StartSize]),
    ?TIMEON,
    search(fun search_list/1,ListBased),
    ?TIMEOFF("List").

do() -> 
    do(dict),
    do(orddict),
    do(list).

search(_Matcher, []) -> ok;
search(Matcher, [#'fun.full.object'{ properties = Element}|Rest]) ->
    Matcher(Element),
    search(Matcher, Rest).

search_dict(Dict) ->
    dict:fetch(?METRIC_VAL_SYSID, Dict),
    dict:fetch(?METRIC_VAL_PROP, Dict),
    dict:fetch(?METRIC_VAL_START_PROP, Dict),
    %dict:fetch(?METRIC_VAL_KEY_PROP, Dict),
    dict:fetch(?METRIC_VAL_ENTITIY_SYSID, Dict),
    dict:fetch(?METRIC_VAL_KEY_ID, Dict).

search_orddict(Orddict) ->
    orddict:fetch(?METRIC_VAL_SYSID, Orddict),
    orddict:fetch(?METRIC_VAL_PROP, Orddict),
    orddict:fetch(?METRIC_VAL_START_PROP, Orddict),
    %orddict:fetch(?METRIC_VAL_KEY_PROP, Orddict),
    orddict:fetch(?METRIC_VAL_ENTITIY_SYSID, Orddict),
    orddict:fetch(?METRIC_VAL_KEY_ID, Orddict).

search_dbdict(Orddict) ->
    orddict:fetch(?METRIC_VAL_SYSID, Orddict),
    orddict:fetch(?METRIC_VAL_PROP, Orddict),
    orddict:fetch(?METRIC_VAL_START_PROP, Orddict),
    %orddict:fetch(?METRIC_VAL_KEY_PROP, Orddict),
    orddict:fetch(?METRIC_VAL_ENTITIY_SYSID, Orddict),
    orddict:fetch(?METRIC_VAL_KEY_ID, Orddict).

search_list(List) ->
    proplists:lookup(?METRIC_VAL_SYSID, List),
    proplists:lookup(?METRIC_VAL_PROP, List),
    proplists:lookup(?METRIC_VAL_START_PROP, List),
    %proplists:lookup(?METRIC_VAL_KEY_PROP, List),
    proplists:lookup(?METRIC_VAL_ENTITIY_SYSID, List),
    proplists:lookup(?METRIC_VAL_KEY_ID, List).

get_mv_list(EntitySysId = <<_:32,_:16,ObjectTypeId:16,_:64>>, Time, Value, MetricKeyId) ->
    [
        { ?METRIC_VAL_ENTITY_TYPE_ID, ObjectTypeId },
        { ?METRIC_VAL_PROP, Value },
        %{ ?METRIC_VAL_KEY_PROP, "yomama.smokes.crack.rock"},
        { ?METRIC_VAL_KEY_ID, MetricKeyId },
        { ?METRIC_VAL_START_PROP, {'date', Time} },
        { ?METRIC_VAL_SYSID, <<0,0,0,0,0,1,0,37,0,0,0,0,0,0,0,1>> },
        { ?METRIC_VAL_ENTITIY_SYSID, EntitySysId }
    ].

create_mv_dict(EntitySysId, Time, Value, MetricKeyId) ->
     % collapse once our list is correct, order matters here
    Properties = dict:from_list(get_mv_list(EntitySysId, Time, Value, MetricKeyId)),

    #'fun.full.object'{
        sysid = <<0,0,0,0,0,1,0,38,0,0,0,0,0,0,0,1>>,
        properties = Properties,
        associations = [ EntitySysId ]
    }.

create_mv_orddict(EntitySysId, Time, Value, MetricKeyId) ->
     % collapse once our list is correct, order matters here
    Properties = orddict:from_list(get_mv_list(EntitySysId, Time, Value, MetricKeyId)),

    #'fun.full.object'{
        sysid = <<0,0,0,0,0,1,0,38,0,0,0,0,0,0,0,1>>,
        properties = Properties,
        associations = [ EntitySysId ]
    }.

create_mv_gbdict(EntitySysId, Time, Value, MetricKeyId) ->
     % collapse once our list is correct, order matters here
    Properties = orddict:from_list(get_mv_list(EntitySysId, Time, Value, MetricKeyId)),

    #'fun.full.object'{
        sysid = <<0,0,0,0,0,1,0,38,0,0,0,0,0,0,0,1>>,
        properties = Properties,
        associations = [ EntitySysId ]
    }.

create_mv_list(EntitySysId, Time, Value, MetricKeyId) ->
     % collapse once our list is correct, order matters here
    Properties = get_mv_list(EntitySysId, Time, Value, MetricKeyId),

    #'fun.full.object'{
        sysid = <<0,0,0,0,0,1,0,38,0,0,0,0,0,0,0,1>>,
        properties = Properties,
        associations = [ EntitySysId ]
    }.
