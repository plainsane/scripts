-module(mems).
-compile(export_all).

print_process_count(_FilterCount, []) -> ok;
print_process_count(FilterCount, [H|Rest]) ->
    {_,Count} = erlang:process_info(H, message_queue_len),
    {_, {Module, Function, _}} = erlang:process_info(H, initial_call),
    case Count >= FilterCount of
        true ->
            io:format("~p has queue count ~p (module info ~p:~p)~n", [H, Count, Module, Function]);
        false -> ok
    end,
    print_process_count(FilterCount, Rest).

process_queue_count() -> process_queue_count(0).
process_queue_count(Count) ->
    Processes = erlang:processes(),
    print_process_count(Count, Processes).

collect_garbage([]) -> ok;
collect_garbage([Pid|Rest]) ->
    erlang:garbage_collect(Pid),
    collect_garbage(Rest).
collect_garbage() ->
    Processes = erlang:processes(),
    collect_garbage(Processes).

print_process_memory([], _) -> ok;
print_process_memory([H|Rest], Min) ->
    {_,BaseSize} = erlang:process_info(H, memory),
    Size = erlang:system_info(wordsize) * BaseSize,
    case Size >= Min of
        true ->
            {_, {Module, Function, _}} = erlang:process_info(H, initial_call),
            io:format("~p has ~p bytes (module info ~p:~p)~n", [H, Size, Module, Function]);
        false ->
            ok
    end,
    print_process_memory(Rest, Min).

process_memory_usage() -> process_memory_usage(0).
process_memory_usage(Size) ->
    Processes = erlang:processes(),
    print_process_memory(Processes, Size).
