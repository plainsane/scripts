-module(dynamicspeed).

-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

-export([execute/2]).

% evDynamic(Count , _, _Value) when Count =:= 0 -> 
%     %io:format("value is ~p", [Value]);
%     ok;
% evDynamic(Count, Expression, Bindings) when is_list(Bindings) ->
%     {value, _EvalResult, _} = erl_eval:exprs( Expression, Bindings),
%     evDynamic(Count - 1, Expression, Bindings);

% evDynamic(Count, Expression, Value) when is_integer(Value) ->
%     Bindings = [{list_to_atom("CURRENT_VALUE"), 3}],
%     {value, _EvalResult, _} = erl_eval:exprs( Expression, Bindings),
%     evDynamic(Count - 1, Expression, Value).
evDynamic(Count, _) when Count =:= 0 -> 
    %io:format("value is ~p", [Value]);
    ok;
evDynamic(Count, Value) ->
    apply(supertest, do, [Value]),
    evDynamic(Count - 1, Value).


evStatic(Count, _) when Count =:= 0-> ok;
evStatic(Count, Value) ->
    _Bind = Value > 100,
    evStatic(Count - 1, Value).


execute(Type, Count) ->
    Code = "CurrentValue > 100. ",
    Value = 3,
    ErlExpr = old_school(Code),
    Bindings = [{list_to_atom("CURRENT_VALUE"), Value}],
    make_module(Code),
    ?TIMEON,
    case Type of
        static ->
            evStatic(Count, Value);
        dynamic ->
            evDynamic(Count, Value)
    end,
    ?TIMEOFF(execute).

old_school(Text)->
    {ok, Tokens, _} = erl_scan:string( string:to_upper( Text )),
    {ok, ErlExpr } = erl_parse:parse_exprs( Tokens ),
    ErlExpr.

make_module(Text) ->
    NewText = "-module(supertest). -export([do/1]). do(CurrentValue) -> " ++ Text,
    compile_and_load(NewText).

do(CurrentValue,  TriggerTime, TriggerState, TransitionTime, State) -> 
    case CurrentValue =< 9 of
        true ->
            case State of 
                level1 ->
                    case TransitionTime >= mvalarm:get_time_span("20 seconds") of
                        true -> trigger;
                        false -> State
                    end;
                _ ->level1   
            end; 
        false -> halt
    end. 

compile_and_load(Text) ->
    try
        Forms = scan_and_parse(Text, 1, []),
        {ok, Mod, Bin} = compile:forms(Forms),
        {module, _M} = code:load_binary(Mod, "generated", Bin),
        io:format(
             "~p:compile_and_load replaced module ~p with [~s]~n",
            [?MODULE, Mod, Text]
         ),
        code:purge(Mod),
         ok
    catch
         Err:Reason ->
            io:format(
                 "compile_and_load failed, err:reason {~p:~p}~n~p~n",
                [Err, Reason, Text]
             ),
            {Err, Reason}
     end.

scan_and_parse([], _Line, Forms) ->
     lists:reverse(Forms);
scan_and_parse(Text, Line, Forms) ->
     {done, {ok, Toks, NLine}, Cont} = erl_scan:tokens([], Text, Line),
     {ok, Form} = erl_parse:parse_form(Toks),
     scan_and_parse(Cont, NLine, [Form|Forms]).

