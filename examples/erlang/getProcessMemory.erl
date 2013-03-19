{ok, ProcessOut} = file:open("/tmp/processSizes.txt", [write, binary]),
ProcSizes = [ begin 
    {_,BaseSize} = erlang:process_info(Proc, memory),
    Size = BaseSize * erlang:system_info(wordsize),
    {_, {Module, Function, _}} = erlang:process_info(Proc, initial_call),                                                                                                                                                                     
    io:format(ProcessOut, "Process:~w.~w ~w~n", [Proc, Module, Size]),
    Size
  end
|| 
    Proc <- erlang:processes()
],
file:close(ProcessOut),
ProcTotalSize = lists:foldl(fun (Value, Acc) -> Value + Acc end, 0, ProcSizes).
