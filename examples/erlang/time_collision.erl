-module(time_collision).
-compile(export_all).
-define(TOTAL, 1000000).
now_micros() ->                                                                                                                                                                                                                  
    T = { Mega, Sec, Micro } = erlang:now(),
    {(Mega * 1000000000000) + (Sec * 1000000) + Micro, T}.

do() ->
    Proc1 = spawn(time_collision, do_stuff, [self(), ?TOTAL, []]),
    Proc2 = spawn(time_collision, do_stuff, [self(), ?TOTAL, []]),
    [R1, R2] = do_receive([]),
    io:format("ok, comparing~n"),
    Resp1 = validate(R1, []),
    io:format("done with validate~n"),
    Resp2 = validate(R2, []),
    io:format("done with validate~n"),
    Set1 = sets:from_list(Resp1),
    Set2 = sets:from_list(Resp2),
    sets:to_list(sets:intersection(Set1, Set2)).

validate([], Accum) -> Accum;
validate([{T, {_, _, Micro}} | Rest], Accum) when Micro >= 1000000 ->
    io:format("found micro greater than 100000 at ~p~n", [Micro]),
    validate(Rest, [T|Accum]);
validate([{T, _} | Rest], Accum) ->
    validate(Rest, [T|Accum]).

do_receive(Accum) ->
    receive
        List when is_list(List) ->
            NewAccum = [List | Accum],
            case length(NewAccum) of
                2 -> NewAccum;
                _ ->
                    io:format("got response~n"),
                    do_receive(NewAccum)
            end;
        _ ->
            io:format("huh?~n"),
            do_receive(Accum)
    end.

do_stuff(Parent, 0, Accum) -> Parent ! Accum;
do_stuff(Parent, Count, Accum) ->
    do_stuff(Parent, Count - 1, [now_micros() | Accum]).
