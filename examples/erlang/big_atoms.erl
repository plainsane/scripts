-module(big_atoms).
-include("/home/astovall/src/adytum/90210/vep/include/io.hrl").

-export([do/0]).

%-on_load(verify_path/0).

-define(SEED, "config.defaults.cpuidmask.mode.80000001.eax.yomama.super duper wootywoo").
-define(COUNT, 1000000).
-define(VEP_PATH, "/home/astovall/src/adytum/90210/vep/ebin/").
-ifndef(TIMEON).
%% Yes, these need to be on a single line to work...
-define(TIMEON, erlang:put(debug_timer, [now()|case erlang:get(debug_timer) == undefined of true -> []; false -> erlang:get(debug_timer) end])).
-define(TIMEOFF(Var), io:format("~s :: ~10.2f ms : ~p~n", [string:copies(" ", length(erlang:get(debug_timer))), (timer:now_diff(now(), hd(erlang:get(debug_timer)))/1000), Var]), erlang:put(debug_timer, tl(erlang:get(debug_timer)))).
-endif.

% verify_path() ->
%     case code:add_path(?VEP_PATH) of
%         true -> ok;
%         Result -> Result
%     end.

do() ->
    io:format("total atom space ~p~n", [erlang:memory(atom)]),
    populate_some_stuff(?COUNT),
    io:format("total atom space used ~p~n", [erlang:memory(atom_used)]),
    piqihelper:encode(#msg_prop{}),
    ok.

populate_some_stuff(0) -> ok;
populate_some_stuff(Count) ->
    case Count rem 100000 of
        0 -> ?TIMEON;
        _ -> ok
    end,
    A = list_to_atom(?SEED ++ integer_to_list(Count)),
    case Count rem 100000 of
        0 -> ?TIMEOFF("insert speed");
        _ -> ok
    end,
    populate_some_stuff(Count - 1).
