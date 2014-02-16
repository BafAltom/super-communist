--[[
##############
# BAFALTOM2D #
##############

A "good enough" and simple-to-use graphic library for the LOVE framework

Deal with "Entities", i.e. any objects with getX() and getY() methods.

]]

function distance2Points(x1, y1, x2, y2)
	local dxx = (x2-x1)
	local dyy = (y2-y1)
	return math.sqrt(dxx^2 + dyy^2)
end

function distance2Entities(ent1, ent2)
	return distance2Points(ent1:getX(), ent1:getY(), ent2:getX(), ent2:getY())
end

function findClosestOf(entities, origin, maxDistance)
	--[[
	-- parameters :
	--		entities				a list of entities
	--		origin					the entity which we want the closest of (that can't be correct English)
	--		maxDistance				nil to disable
	-- return :
	--		the closest entity		(nil if the list is empty or maxDistance was provided and too restrictive)
	--		the	distance			(nil if the list is empty or maxDistance was provided and too restrictive)
	-- remark(s) :
	--		if origin is present in entities, it will be ignored
	]]

	if #entities == 0 then
		return nil, nil
	end

	if (not maxDistance) then
		maxDistance = 2*distance2Entities(entities[1], origin)
	end

	local closestEnt = nil
	local closestDistance = maxDistance

	for _,e in ipairs(entities) do
		if e~= origin and math.abs(e:getX() - origin:getX()) < closestDistance and math.abs(e:getY() - origin:getY()) < closestDistance then
			local _distance = distance2Entities(e, origin)
			if (_distance < closestDistance) then
				closestEnt = e
				closestDistance = _distance
			end
		end
	end
	return closestEnt, closestDistance
end

function bafaltomVector(startX, startY, endX, endY, desiredNorm)
	-- return the (x,y) coordinates of a vector of direction (startX, startY)->(endX, endY) and of norm desiredNorm
	local _currentNorm = distance2Points(startX, startY, endX, endY)
	local _normFactor = desiredNorm / _currentNorm
	local _dx = endX - startX
	local _dy = endY - startY
	return _dx*_normFactor, _dy*_normFactor
end

function bafaltomAddVectors(...)
	-- args: vx1, vy1, vx2, vy2, ...
	local x,y = 0,0
	for i = 1,#args,2 do
		x, y = x + args[i], y + args[i+1]
	end
	return x, y
end

function dotProduct(v1x, v1y, v2x, v2y)
	return v1x*v2x + v1y + v2y
end

function bafaltomAngle(x1, y1, x2, y2)
	-- return the angle between the line ((x1, y1),(x2,y2)) and the horizontal line in (x1,y1)
	return math.atan2(y2-y1,x2-x1)
end

function bafaltomAngle2Entities(e1, e2)
	return bafaltomAngle(e1:getX(), e1:getY(), e2:getX(), e2:getY())
end
