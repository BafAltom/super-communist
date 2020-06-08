export *

isInSubMap = (x, y) ->
    x < mapMinX or x > mapMaxX or y < mapMinY or y > mapMaxY

randomPointInSubMapCorners = ->
    isDown = math.random(0,1)
    isRight = math.random(0,1)
    cornerX = math.random(0, subMapMaxX - mapMaxX)
    cornerY = math.random(0, subMapMaxY - mapMaxY)

    randPX = -subMapMaxX + isRight * (subMapMaxX + mapMaxX) + cornerX
    randPY = -subMapMaxY + isDown * (subMapMaxY + mapMaxY) + cornerY
    return randPX, randPY

isNan = (x) ->
    x ~= x

table.clone = (t) ->
    {unpack(t)}
