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

findClosestOf = function(entities, origin, maxDistance)
	--[[
	-- parameters :
	--		entities		a list of entities
	--		origin			the entity which we want the closest of (that can't be correct English)
	--		maxDistance		0 to disable
	-- return :
	--		an entity		which is the closest in the list
	--		nil				if the list is empty or maxDistance was provided and too restrictive
	-- remark(s) :
	--		if origin is present in entities, it will be ignored
	]]

	local closestEnt = nil
	local closestDistance = maxDistance

	for _,e in ipairs(entities) do
		if (maxDistance == 0
			or math.abs(e:getX() - origin:getX()) < closestDistance -- optimization
			or math.abs(e:getY() - origin:getY()) < closestDistance
			) then
			local temp_distance = distance2Entities(e, origin)
			if (temp_distance < closestDistance and e ~= origin) then
				closestEnt = e
				closestDistance = temp_distance
			end
		end
	end

	return closestEnt
end

function bafaltomVector(startX, startY, endX, endY, desiredNorm)
	-- return the (x,y) coordinates of a vector of direction (startX, startY)->(endX, endY) and of norm desiredNorm
	local _currentNorm = distance2Points(startX, startY, endX, endY)
	local _normFactor = desiredNorm / _currentNorm
	local _dx = endX - startX
	local _dy = endY - startY
	return _dx*_normFactor, _dy*_normFactor
end

function bafaltomAngle(x1, y1, x2, y2)
	-- return the angle between the line ((x1, y1),(x2,y2)) and the horizontal line in (x1,y1)
	return math.atan2(y2-y1,x2-x1)
end

function bafaltomAngle2Entities(e1, e2)
	return bafaltomAngle(e1:getX(), e1:getY(), e2:getX(), e2:getY())
end