{ok, EtsOut} = file:open("/tmp/etsSizes.txt", [write, binary]),
EtsSizes = [ begin 
    Size = ets:info(Table, memory) * erlang:system_info(wordsize),
    io:format(EtsOut, "Table:~w ~w~n", [Table, Size]),
    Size
  end
|| 
    Table <- ets:all() 
],
file:close(EtsOut),
EtsTotalSize = lists:foldl(fun (Value, Acc) -> Value + Acc end, 0, EtsSizes).
