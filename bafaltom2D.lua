function distance2Points(x1, y1, x2, y2)
	local dxx = (x2-x1)
	local dyy = (y2-y1)
	return math.sqrt(dxx^2 + dyy^2)
end

	--[[
	assert(distance2Points(0,0,3,4) == 5)
	assert(distance2Points(1,2,1,2) == 0)
	assert(distance2Points(5,5,6,6) == math.sqrt(2))
	--]]

function distance2Entities(ent1, ent2)
	return distance2Points(ent1.x, ent1.y, ent2.x, ent2.y)
end

findClosestOf = function(entities, origin, maxDistance)
	-- parameters :
	--		entities		a list of entities (e.g. "dudes" or "coins")
	--		origin			the entity which we want the closest of (that can't be correct English)
	--		maxDistance		0 to disable
	-- return :
	--		an entity		which is the closest in the list
	--		nil				if the list is empty or maxDistance was provided and too restrictive
	-- remark(s) :
	--		if origin is present in entities, it will be ignored

	local closestEnt = nil
	local closestDistance = maxDistance

	for _,e in ipairs(entities) do
		if (maxDistance == 0
			or math.abs(e.x - origin.x) < closestDistance -- optimization
			or math.abs(e.y - origin.y) < closestDistance
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

function myVector(startX, startY, endX, endY, desiredNorm)
	-- return the (x,y) coordinates of a vector of direction (startX, startY)->(endX, endY) and of norm desiredNorm
	local _currentNorm = distance2Points(startX, startY, endX, endY)
	local _normFactor = desiredNorm / _currentNorm
	local _dx = endX - startX
	local _dy = endY - startY
	return _dx*_normFactor, _dy*_normFactor
end
