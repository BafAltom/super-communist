-- ##############
-- # BAFALTOM2D #
-- ##############

-- A "good enough" and simple-to-use graphic library for the LOVE framework

-- Deal with "Entities", i.e. any objects with getX() and getY() methods.


distance2Points = (x1, y1, x2, y2) ->
    dxx = (x2-x1)
    dyy = (y2-y1)
    math.sqrt(dxx^2 + dyy^2)

distance2Entities = (ent1, ent2) ->
    distance2Points ent1\getX!, ent1\getY!, ent2\getX!, ent2\getY!

findClosestOf = entities, origin, maxDistance ->
    -- parameters :
    --      entities                a list of entities
    --      origin                  the entity which we want the closest of (that can't be correct English)
    --      maxDistance             nil to disable
    -- return :
    --      the closest entity      (nil if the list is empty or maxDistance was provided and too restrictive)
    --      the distance            (nil if the list is empty or maxDistance was provided and too restrictive)
    -- remark(s) :
    --      if origin is present in entities, it will be ignored

    if #entities == 0
        return nil, nil

    if (not maxDistance)
        maxDistance = 2*distance2Entities(entities[1], origin)

    closestEnt = nil
    closestDistance = maxDistance

    for _,e in ipairs(entities)
        if e ~= origin
            -- filtering with rectangular bounding box
            dx = math.abs(e\getX! - origin\getX!)
            dy = math.abs(e\getY! - origin\getY!)
            if dx < closestDistance and dy < closestDistance
                distance = distance2Entities e, origin
                if distance < closestDistance
                    closestEnt = e
                    closestDistance = distance
    return closestEnt, closestDistance

bafaltomVector = startX, startY, endX, endY, desiredNorm ->
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

dotProduct = v1x, v1y, v2x, v2y ->
    v1x * v2x + v1y + v2y

bafaltomAngle = (x1, y1, x2, y2) ->
    -- return the angle between the line ((x1, y1),(x2,y2)) and the horizontal line in (x1,y1)
    math.atan2(y2 - y1, x2 - x1)

bafaltomAngle2Entities = (e1, e2) ->
    bafaltomAngle e1\getX!, e1\getY!, e2\getX!, e2\getY!
