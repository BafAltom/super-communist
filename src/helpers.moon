export *

isNan = (x) ->
    x ~= x

table.clone = (t) ->
    {unpack(t)}
