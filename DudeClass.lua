DudeClass = {}

-- STATIC ATTRIBUTES
DudeClass.currentID = 0

-- STATIC METHODS
DudeClass.giveNextID = function()
	DudeClass.currentID = DudeClass.currentID + 1
	return DudeClass.currentID
end

-- CLASS METHODS
DudeClass.draw = function(dude)
		-- choose color
		if (dude:class() == "poor") then
			love.graphics.setColor(255,0,0)
		elseif (dude:class() == "middle") then
			love.graphics.setColor(0,255,0)
		elseif (dude:class() == "rich") then
			love.graphics.setColor(0,0,255)
		elseif (dude:class() == "rich+") then
			love.graphics.setColor(255,255,255)
		end


		---[[ SIMPLE GRAPHICS
		-- draw shape
		dudeSize = dude:dudeSize()
		if (dude.invulnTimer <= 0) then
			fillage = "fill"
		else
			fillage = "line"
		end
		love.graphics.rectangle(fillage, dude.x - dudeSize/2, dude.y - dudeSize/2, dudeSize, dudeSize)
		if (DEBUG) then
			love.graphics.print(dude.id, dude.x + dudeSize + 5, dude.y)
		end
		--]]

		--[[ PICTURE GRAPHICS
		if (dude.invulnTimer > 0) then
			alpha = 100
		else
			alpha = 255
		end
		_r, _g, _b, _a = love.graphics.getColor()
		love.graphics.setColor(_r, _g,_b, alpha)
		dudePic = dude:getDudePic()
		love.graphics.draw(dudePic, dude.x, dude.y, 0, dude:dudeSize()/dudePic:getWidth(), 1.5*dude:dudeSize()/dudePic:getHeight(), dude:dudeSize()*1.5, 2*dude:dudeSize(), 0, 0)
		--love.graphics.circle("line", dude.x, dude.y, dude:dudeSize())
		--]]

	-- draw prey circle
	--[[
	if (dude:class() == "rich") then
		love.graphics.circle("line", dude.x, dude.y, dude:preyRadius(), 50)
	end
	--]]

	-- draw lightning
	if (dude.attackTimer > 0 and not (dude:class() == "rich+")) then
		attackedDude = dudes.find(dude.attacked)
		love.graphics.setColor(255,255,0)
		love.graphics.line(dude.x, dude.y, attackedDude.x, attackedDude.y)
	end

	-- draw dest Path
	if (DEBUG) then
		love.graphics.line(dude.x, dude.y, dude.destX, dude.destY)
	end
end

DudeClass.class  = function(dude)
	if (dude.money <= moneyMaxPoor) then
		return "poor"
	elseif (dude.money <= moneyMaxMiddle) then
		return "middle"
	elseif (dude.money < moneyMaxRich) then
		return "rich"
	else
		return "rich+"
	end
end

DudeClass.update = function(dude,dt)
	-- dude movement
	dude.x = dude.x + dude.speedX*dt
	dude.y = dude.y + dude.speedY*dt

	-- dude pathfinding
	-- arrived at destination?
	if(distance2Points(dude.x,dude.y,dude.destX,dude.destY) <= destAcceptanceRadius) then
		dude.fleeing = false
		if (dude.waitingTime > 0) then
			dude.waitingTime = dude.waitingTime - dt
		else
			dude:findNewDestination()
		end
	else
		-- attracted by coins
		closestCoin = dude:findClosestCoin()
		if (closestCoin ~= nil and not dude.fleeing and not (dude:class() == "rich+")) then
			dude.destX = closestCoin.x
			dude.destY = closestCoin.y
		end
		-- rich+ dudes are attracted to player
		if (dude:class() == "rich+" and distance2Entities(dude, player) > richPlusStalkDistance) then
			dude.destX = player.x
			dude.destY = player.y
		end

		-- no distracion --> go to destination
		dude.speedX = (dude.destX - dude.x)
		dude.speedY = (dude.destY - dude.y)

		dude:calculateSpeed()
	end

	-- prey on the weak
	if (dude:class() == "rich" and not (dude.invulnTimer > 0)) then
		for _, prey in ipairs(dudes) do
			if (prey.money < dude.money
				and distance2Entities(dude, prey) < dude:preyRadius()
				and not (prey.invulnTimer > 0)
				and not (dude.attackTimer > 0)
				and dude.id ~= prey.id)
			then
				dude.attacked = prey.id
				dude.attackTimer = richHitTimer
				stolenMoney = math.min(prey.money, moneyStolenByHit)
				prey:isAttacked(dude, stolenMoney)
			end
		end
	end

	-- rich+ shoot Fireballz
	if (dude:class() == "rich+"
		and not (dude.attackTimer > 0)
		and distance2Entities(dude, player) < superRichHitDistance)
	then
		FireBallClass.createFireBall(dude,player.x,player.y)
		dude.attackTimer = fireBallAttackTimer -- tochange
		dude.attacked = 0
	end

	-- flee
	if (dude.attackedBy ~= -1) then
		attacker = dudes.find(dude.attackedBy)
		dude.destX = dude.x + 2*(dude.x - attacker.x)
		dude.destY = dude.y + 2*(dude.y - attacker.y)
		dude.destX = math.max(dude.destX, fleeMinX)
		dude.destX = math.min(dude.destX, fleeMaxX)
		dude.destY = math.max(dude.destX, fleeMinY)
		dude.destY = math.min(dude.destX, fleeMaxY)
		dude.attackedBy = -1
		dude.fleeing = true
	end

	-- push or be pushed by other players
	closestDude = findClosestOf(dudes, dude, dude:dudeSize())
	if (closestDude ~= nil) then
		dude:dudePush(closestDude)
	end

	-- timer
		if (dude.invulnTimer > 0) then dude.invulnTimer = dude.invulnTimer - dt end
		if (dude.attackTimer > 0) then dude.attackTimer = dude.attackTimer - dt end
end

DudeClass.updateMoney = function(dude, amount)
-- negative/positive amount : take/give money
	dude.money = dude.money + amount

end

DudeClass.dudePush = function(dude, smallerDude)
	if (not (dude.x == smallerDude.x and dude.y == smallerDude.y)) then
		-- NEW WAY
		translationX, translationY = myVector(dude.x, dude.y, smallerDude.x, smallerDude.y, dude:dudeSize())
		smallerDude.x, smallerDude.y = dude.x + translationX, dude.y + translationY
	else -- hotfix
		smallerDude.x = smallerDude.x + dude:size()
	end
end

DudeClass.preyRadius = function(dude)
	if (dude:class() ~= "rich") then
		return 0
	else
		return dude.money*moneyRadiusFactor
	end
end

DudeClass.findClosestCoin = function(dude)
	return findClosestOf(coins, dude, dudeAttractionDistance)
end


DudeClass.dudeSize = function(dude)
	return math.max(5, dude.money/10)
end

DudeClass.isAttacked = function(dude, predator, moneyStolen)
	dude:updateMoney(-1*moneyStolen)
	CoinClass.createCoinBatch(dude.x, dude.y, moneyStolen)
	dude.attackedBy = predator.id
	dude.invulnTimer = invulnTimeByHit

end

DudeClass.findNewDestination = function(dude)
	if (dude:class() == "poor" and not isInSubMap(dude.x, dude.y)) then
		 -- poor go to the closest suburbs corner
		if (dude.x - subMapMinX < subMapMaxX - dude.x) then dude.destX = subMapMinX else dude.destX  = subMapMaxX end
		if (dude.y - subMapMinY < subMapMaxY - dude.y) then dude.destY = subMapMinY else dude.destY  = subMapMaxY end
	else
		dude.destX = math.random(dude.x - dudeNextDestRadius, dude.x + dudeNextDestRadius)
		dude.destY = math.random(dude.y - dudeNextDestRadius, dude.y + dudeNextDestRadius)

		if (dude:class() == "poor") then
			limitMinX = subMapMinX
			limitMaxX = subMapMaxX
			limitMinY = subMapMinY
			limitMaxY = subMapMaxY
		else
			limitMinX = mapMinX
			limitMaxX = mapMaxX
			limitMinY = mapMinY
			limitMaxY = mapMaxY
		end
		dude.destX = math.max(limitMinX, dude.destX)
		dude.destX = math.min(limitMaxX, dude.destX)
		dude.destY = math.max(limitMinY, dude.destY)
		dude.destY = math.min(limitMaxY, dude.destY)
	end
end

DudeClass.calculateSpeed = function(dude)

	actualSpeed = math.sqrt(dude.speedX^2 + dude.speedY^2)
	if (actualSpeed > dudeMaxSpeed) then
		dude.speedX, dude.speedY = myVector(0,0,dude.speedX, dude.speedY, dudeMaxSpeed)
	end
end

DudeClass.getDudePic = function(dude)

	if (dude:class() == "poor") then
		return picPoor
	elseif (dude:class() == "middle") then
		return picMiddle
	elseif (dude:class() == "rich") then
		return picRich
	else
		return picRichPlus
	end

end

-- CONSTRUCTOR
DudeClass.new = function(x, y, money)
	littleDude = {}
	setmetatable(littleDude, {__index = DudeClass})

	littleDude.id = DudeClass.giveNextID()
	littleDude.money = math.random((moneyMaxMiddle + moneyMaxRich)/2)
	if (DudeClass.class(littleDude) ~= "poor") then
		littleDude.x = math.random(mapMinX, mapMaxX)
		littleDude.y = math.random(mapMinY, mapMaxY)
	else
		-- ToDo : generation mieux repartie dans la submap
		littleDude.x = math.random(subMapMinX, subMapMaxX)
		if (littleDude.x < mapMinX or littleDude.x > mapMaxX) then
			littleDude.y = math.random(subMapMinY, subMapMaxY)
		else
			littleDude.y = math.random(subMapMinY, mapMinY)
		end
	end
	littleDude.destX = littleDude.x
	littleDude.destY = littleDude.y
	littleDude.speedX = 0
	littleDude.speedY = 0
	littleDude.waitingTime = math.random(0,1)
	littleDude.invulnTimer = 0
	littleDude.fleeing = false
	littleDude.attacked = -1
	littleDude.attackedBy = -1
	littleDude.attackTimer = 0

	return littleDude
end

-----------------------------------------------------

dudes = {}

poorCount = 0
middleCount = 0
richCount = 0
for i=1,numberOfDudes do
	dudeState = math.random(100)
	if (dudeState < poorPercent) then -- poor
		poorCount = poorCount + 1
		dudeX, dudeY = randomPointInSubMapCorners()
		dudeM = math.random(0, moneyMaxPoor)
	else
		dudeX = math.random(mapMinX, mapMaxX)
		dudeY = math.random(mapMinY, mapMaxY)

		if (dudeState < poorPercent + middlePercent) then -- middle
			middleCount = middleCount + 1
			dudeM = math.random(moneyMaxPoor + 1, moneyMaxMiddle)
		else -- rich
			richCount = richCount + 1
			dudeM = math.random(moneyMaxMiddle + 1, moneyMaxRich)
		end
	end
	table.insert(dudes, DudeClass.new(dudeX, dudeY, dudeM))
end
print("poor/middle/rich : ", poorCount, middleCount, richCount)

dudes.find = function(id)
	if (id == 0) then
		return player
	end

	for _, d in ipairs(dudes) do
		if (d.id == id) then return d end
	end
	return nil
end

dudes.allMiddle = function()
	for _, d in ipairs(dudes) do
		if (d:class() ~= "middle") then
			return false
		end
	end
	return true
end
