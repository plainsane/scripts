-module(ets_matchspec).

-export([do/0]).


do() ->
    Table = ets:new(no_bagger, [ set, private ]),
    ets:insert(Table, [{{1,2}, [{1,2,3},{4,5,6},{7,8,9}]}]),
    Spec = [{{ {'$1', 2},['$2'|'_']},[{ '=:=', {element, 2, '$2'}, 5 } ],['$1']}],
    ets:select( Table, Spec ).
