-- ##############
-- # BAFALTOM2D #
-- ##############

-- A "good enough" and simple-to-use graphic library for the LOVE framework

-- Deal with "Entities", i.e. any objects with getX() and getY() methods.

export *

class Entity
    new: (@x, @y) =>
        @id = nil

    getX: =>
        @x

    getY: =>
        @y

class EntityList
    new: =>
        @currentID = 0
        @entList = {}

    nextID: =>
        @currentID += 1
        return @currentID

    iter: =>
        i = #@entList + 1
        return ->
            i -= 1
            return @entList[i] if i >= 1

    as_list: =>
        return @entList

    add: (ent) =>
        ent.id = @nextID!
        table.insert @entList, ent

    find: (id) =>
        for _, e in ipairs @entList
            if e.id == id
                return e
        return nil

    removeID: (id) =>
        for n, e in ipairs @entList
            if e.id == id
                table.remove @entList, n
                return

distance2Points = (x1, y1, x2, y2) ->
    dxx = (x2-x1)
    dyy = (y2-y1)
    math.sqrt(dxx^2 + dyy^2)

distance2Entities = (ent1, ent2) ->
    distance2Points ent1\getX!, ent1\getY!, ent2\getX!, ent2\getY!

findClosestOf = (candidates, origin, maxDistance=nil) ->
    -- Returns the entity from candidates closest to origin with a distance less
    --  than maxDistance (if specified)
    -- parameters:
    --      candidates:  Entity list
    --      origin:      Entity
    --      maxDistance: number (or nil)
    -- return:
    --      two values: closest entity, distance
    --      (or nil, nil if there are no acceptable candidates)
    -- remark:
    --      if origin is present in entities, it will be ignored

    if #candidates == 0
        return nil, nil

    if maxDistance == nil
        -- work with a copy of the original array
        candidatesCopy = table.clone(candidates)

        -- use the distance to an arbitrary candidate as maxDistance
        while candidatesCopy[1] == origin
            table.remove candidatesCopy, 1
        if #candidatesCopy == 0
            return nil, nil
        maxDistance = distance2Entities origin, candidatesCopy[1]

    closestCandidate = nil
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
