-- ##############
-- # BAFALTOM2D #
-- ##############

-- A "good enough" and simple-to-use graphic library for the LOVE framework

-- Deal with "Entities", i.e. any objects with getX() and getY() methods.

export *

class Entity
    new: (@x, @y) =>

    getX: =>
        @x

    getY: =>
        @y

distance2Points = (x1, y1, x2, y2) ->
    dxx = (x2-x1)
    dyy = (y2-y1)
    math.sqrt(dxx^2 + dyy^2)

distance2Entities = (ent1, ent2) ->
    distance2Points ent1\getX!, ent1\getY!, ent2\getX!, ent2\getY!

findClosestOf = (candidates, origin, maxDistance) ->
    -- Returns the entity from entities closest to origin with a distance less
    --  than maxDistance (if specified)
    -- parameters:
    --      candidates:  Entity
    --      origin:      Entity
    --      maxDistance: number (or nil)
    -- return:
    --      two values: closest entity, distance
    --      (or nil, nil if there are no acceptable candidates)
    -- remark:
    --      if origin is present in entities, it will be ignored

    if #candidates == 0
        return nil, nil

    if maxDistance = nil
        -- make sure the first candidate is not the origin
        while candidates[1] == origin
            table.remove candidates, 1
        if #candidates == 0
            return nil, nil
        -- set maxDistance to the first distance
        maxDistance = distance2Entities origin, candidates[1]

    closestCandidate = candidates[1]
    closestDistance = maxDistance

    for _,e in ipairs(candidates)
        if e ~= origin
            -- filtering with rectangular bounding box
            dx = math.abs(e\getX! - origin\getX!)
            dy = math.abs(e\getY! - origin\getY!)
            if dx < closestDistance and dy < closestDistance
                -- if the bbox check passes, perform actual distance check
                distance = distance2Entities e, origin
                if distance < closestDistance
                    closestCandidate = e
                    closestDistance = distance
    return closestCandidate, closestDistance

bafaltomVector = (startX, startY, endX, endY, desiredNorm) ->
    -- return the (x,y) coordinates of a vector of direction (startX, startY)->(endX, endY) and of norm desiredNorm
    currentNorm = distance2Points startX, startY, endX, endY
    normFactor = desiredNorm / currentNorm
    dx = endX - startX
    dy = endY - startY
    return dx * normFactor, dy * normFactor

bafaltomAddVectors = (...) ->
    -- args: vx1, vy1, vx2, vy2, ...
    x,y = 0, 0
    for i = 1,#args, 2
        x, y = x + args[i], y + args[i + 1]
    return x, y

dotProduct = (v1x, v1y, v2x, v2y) ->
    v1x * v2x + v1y + v2y

bafaltomAngle = (x1, y1, x2, y2) ->
    -- return the angle between the line ((x1, y1),(x2,y2)) and the horizontal line in (x1,y1)
    math.atan2(y2 - y1, x2 - x1)

bafaltomAngle2Entities = (e1, e2) ->
    bafaltomAngle e1\getX!, e1\getY!, e2\getX!, e2\getY!
