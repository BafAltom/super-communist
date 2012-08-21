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
		local _dudeColors
		if (dude:class() == "poor") then
			_dudeColors = {255,0,0}
		elseif (dude:class() == "middle") then
			_dudeColors = {0,255,0}
		elseif (dude:class() == "rich") then
			_dudeColors = {0,0,255}
		elseif (dude:class() == "rich+") then
			_dudeColors = {255,255,255}
		end
		love.graphics.setColor(_dudeColors)

		---[[ SIMPLE GRAPHICS
		-- draw shape
		local _dudeSize = dude:dudeSize()
		local _fillage
		if (dude.invulnTimer <= 0) then
			_fillage = "fill"
		else
			_fillage = "line"
		end
		love.graphics.rectangle(_fillage, dude.x - _dudeSize/2, dude.y - _dudeSize/2, _dudeSize, _dudeSize)
		if (DEBUG) then
			love.graphics.print(dude.id, dude.x + _dudeSize + 5, dude.y)
			love.graphics.print(dude.state, dude.x + _dudeSize + 5, dude.y + 10)
			if (dude:class() == 'rich') then
				love.graphics.print(dude.attackTimer, dude.x + _dudeSize + 5, dude.y + 20)
			end
		end
		--]]

		---[[ PICTURE GRAPHICS
		if (dude.dudeAnim and dude.dudePic) then
			love.graphics.setColorMode("replace")
			local _directionIsLeft = 1
			if (dude.speedX > 0) then
				_directionIsLeft = -1
			end
			dude.dudeAnim:draw(dude.dudePic, dude.x, dude.y, 0, _directionIsLeft, 1, dude.dudePic:getWidth()/2)
			love.graphics.setColorMode("modulate")
		end
		--]]

	-- draw prey circle
	--[[
	if (dude:class() == "rich") then
		love.graphics.circle("line", dude.x, dude.y, dude:preyRadius(), 50)
	end
	--]]

	-- draw lightning
	if (dude.currentPrey ~= nil and not (dude:class() == "rich+")) then
		local _attackedDude = dude.currentPrey
		local _attackBuildUpFactor = dude.attackTimer/richHitTimer
		local _distance = distance2Entities(dude, _attackedDude)
		local _endX, _endY = myVector(dude.x, dude.y, _attackedDude.x, _attackedDude.y, _distance*_attackBuildUpFactor)
		love.graphics.setColor(255,255,0, 255*_attackBuildUpFactor)
		love.graphics.line(dude.x, dude.y, dude.x + _endX, dude.y + _endY)
	end

	-- draw dest Path
	if (DEBUG) then
		love.graphics.setColor(_dudeColors)
		love.graphics.line(dude.x, dude.y, dude.destX, dude.destY)
	end
end

DudeClass.class  = function(dude)
	local _dudeMoney = dude.money
	if (_dudeMoney <= moneyMaxPoor) then
		return "poor"
	elseif (_dudeMoney <= moneyMaxMiddle) then
		return "middle"
	elseif (_dudeMoney < moneyMaxRich) then
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
		if (dude.state ~= 'waiting') then
			dude.speedX = 0
			dude.speedY = 0
			dude:setState('waiting')
			dude.waitingTime = math.random(dudeNextDestWaitTimeMin,dudeNextDestWaitTimeMax)
		elseif (dude.waitingTime > 0) then
			dude.waitingTime = dude.waitingTime - dt
		else
			dude:findNewDestination()
			dude:setState('walking')
		end
	else
		-- attracted by coins
		local closestCoin = dude:findClosestCoin()
		if (closestCoin ~= nil and dude.state ~= 'fleeing' and (dude:class() ~= "rich+")) then
			dude.destX = closestCoin.x
			dude.destY = closestCoin.y
			dude:setState('moneyPursuing')
		end
		if (closestCoin == nil and dude.state == 'moneyPursuing') then
			-- the dude was previously attracted by a coin but it doesn't exist
			dude.destX = dude.x
			dude.destY = dude.y
		end

		-- rich+ dudes are attracted to player
		if (dude:class() == "rich+" and distance2Entities(dude, player) > richPlusStalkDistance) then
			dude.destX = player.x
			dude.destY = player.y
			dude:setState('playerPursuing')
		end

		-- no distraction --> go to destination
		dude.speedX = (dude.destX - dude.x)
		dude.speedY = (dude.destY - dude.y)

		dude:calculateSpeed()
	end

	-- prey on the weak
	if (dude:class() == "rich") then
		if (dude.invulnTimer <= 0 and dude.state == "walking" or dude.state == "waiting") then
			local _prey = dude:findClosestPrey()
			if (_prey ~= nil) then
				if (dude.attackTimer > richHitTimer) then
					dude.attackTimer = 0
					dude.attacked = _prey.id
					dude.attackTimer = richHitTimer
					local _stolenMoney = math.min(_prey.money, moneyStolenByHit)
					_prey:isAttacked(dude, _stolenMoney)
				else
					dude.attackTimer = dude.attackTimer + dt
				end
			else
				dude.attackTimer = 0
			end
			dude.currentPrey = _prey
		else
			dude.attackTimer = 0
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
		local _attacker = dudes.find(dude.attackedBy)
		local _destX = dude.x + 2*(dude.x - _attacker.x)
		local _destY = dude.y + 2*(dude.y - _attacker.y)
		_destX = math.max(_destX, fleeMinX)
		_destX = math.min(_destX, fleeMaxX)
		_destY = math.max(_destY, fleeMinY)
		_destY = math.min(_destY, fleeMaxY)
		dude.destX, dude.destY = _destX, _destY
		dude.attackedBy = -1
		dude:setState('fleeing')
	end

	-- push or be pushed by other players
	local _closestDude = findClosestOf(dudes, dude, dude:dudeSize())
	if (_closestDude ~= nil) then
		dude:dudePush(_closestDude)
	end

	-- animation
	if (dude.dudeAnim ~= nil) then
		dude.dudeAnim:update(dt)
	end

	-- timer
	if (dude.invulnTimer > 0) then dude.invulnTimer = dude.invulnTimer - dt end
	if (dude:class() == "rich+" and dude.attackTimer > 0) then dude.attackTimer = dude.attackTimer - dt end
end

DudeClass.updateMoney = function(dude, amount) -- negative/positive amount : take/give money
	local _previousClass = dude:class()
	dude.money = dude.money + amount
	if (dude:class() ~= _previousClass) then
		dude:changeClass(_previousClass)
	end

end

DudeClass.changeClass = function(dude, previousClass)
	if (previousClass == "rich") then
		dude.currentPrey = nil
	end
	dude.waitingTime = invulnTimeByClassChange
	dude:setState("waiting")
end

DudeClass.dudePush = function(dude, smallerDude)
	if (not (dude.x == smallerDude.x and dude.y == smallerDude.y)) then
		local _translationX, _translationY = myVector(dude.x, dude.y, smallerDude.x, smallerDude.y, dude:dudeSize())
		smallerDude.x, smallerDude.y = dude.x + _translationX, dude.y + _translationY
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

DudeClass.findClosestPrey = function(richDude)

	local _filteredDudes = {}
	for _, d in ipairs(dudes) do
		if (d.money < richDude.money and not (d.invulnTimer > 0)) then
			table.insert(_filteredDudes, d)
		end
	end

	return findClosestOf(_filteredDudes, richDude, richDude:preyRadius())
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

		local _limitMinX, _limitMaxX, _limitMinY, _limitMaxY
		if (dude:class() == "poor") then
			_limitMinX = subMapMinX
			_limitMaxX = subMapMaxX
			_limitMinY = subMapMinY
			_limitMaxY = subMapMaxY
		else
			_limitMinX = mapMinX
			_limitMaxX = mapMaxX
			_limitMinY = mapMinY
			_limitMaxY = mapMaxY
		end
		dude.destX = math.max(_limitMinX, dude.destX)
		dude.destX = math.min(_limitMaxX, dude.destX)
		dude.destY = math.max(_limitMinY, dude.destY)
		dude.destY = math.min(_limitMaxY, dude.destY)
		dude:setState('walking')
	end
end

DudeClass.calculateSpeed = function(dude)

	local _actualSpeed = math.sqrt(dude.speedX^2 + dude.speedY^2)
	if (_actualSpeed > dudeMaxSpeed) then
		dude.speedX, dude.speedY = myVector(0,0,dude.speedX, dude.speedY, dudeMaxSpeed)
	end
end

DudeClass.refreshDudeAnimation = function(dude)
-- update the dudePic and dudeAnim attributes of dude
-- there's probably a clever way to do it (with less copypaste)
	local _dudeP, _dudeA = nil, nil
	if (dude:class() == "poor") then
		if (dude.state == "waiting") then
			_dudeP, _dudeA =  picPoorIdle, anim8.newAnimation("loop", dudeGrid('1,1-4'), 0.3)
		elseif (dude.state == "walking") then
			_dudeP, _dudeA = picPoorWalking, anim8.newAnimation("loop", dudeGrid('1,1-4'), 0.2)
		elseif (dude.state == "fleeing") then
			_dudeP, _dudeA = picPoorRunning, anim8.newAnimation("loop", dudeGrid('1,1-4'), 0.15)
		elseif (dude.state == "moneyPursuing") then
			_dudeP, _dudeA = picPoorMoney, anim8.newAnimation("loop", dudeGrid('1,1-4'), 0.15)
		end
	elseif (dude:class() == "middle") then
		if (dude.state == "waiting") then
			_dudeP, _dudeA =  picMiddleIdle, anim8.newAnimation("loop", dudeGrid('1,1-4'), 0.3)
		elseif (dude.state == "walking") then
			_dudeP, _dudeA = picMiddleWalking, anim8.newAnimation("loop", dudeGrid('1,1-4'), 0.2)
		elseif (dude.state == "fleeing") then
			_dudeP, _dudeA = picMiddleRunning, anim8.newAnimation("loop", dudeGrid('1,1-4'), 0.15)
		elseif (dude.state == "moneyPursuing") then
			_dudeP, _dudeA = picMiddleMoney, anim8.newAnimation("loop", dudeGrid('1,1-4'), 0.15)
		end
	end

	dude.dudePic, dude.dudeAnim = _dudeP, _dudeA
end

DudeClass.acceptedStates = {'waiting', 'walking', 'fleeing', 'moneyPursuing', 'playerPursuing'}
DudeClass.setState = function(dude, newState)
	for _,s in ipairs(DudeClass.acceptedStates) do
		if (newState == s) then
			dude.state = newState
			dude:refreshDudeAnimation()
			return
		end
	end

	error('Dude.setState(newState) : newState = '..newState..' was not in accepted states')

end

-- CONSTRUCTOR
DudeClass.new = function(x, y, money)
	local littleDude = {}
	setmetatable(littleDude, {__index = DudeClass})

	littleDude.id = DudeClass.giveNextID()
	littleDude.money = money
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
	littleDude.waitingTime = 0
	littleDude.invulnTimer = 0
	littleDude.currentPrey = nil -- current target dude
	littleDude.attacked = -1 -- id of attacked dude (-1 if void)
	littleDude.attackedBy = -1 -- id of attacking dude (-1 if void)
	littleDude.attackTimer = 0 -- beware : used by rich and rich+ but behave differently (increase for rich, decrease for rich+) (this is obviously stupid and should be refactored -> TODO)
	littleDude.state = ''
	littleDude.dudePic = nil
	littleDude.dudeAnim = nil
	littleDude:findNewDestination()
	littleDude:setState('walking')

	return littleDude
end

-----------------------------------------------------

dudes = {}

local _poorCount, _middleCount , _richCount = 0, 0, 0
for i = 1, numberOfDudes do
	local _dudeX, _dudeY, _dudeM
	local _randomPercent = math.random(100)
	if (_randomPercent < poorPercent) then -- poor
		_poorCount = _poorCount + 1
		_dudeX, _dudeY = randomPointInSubMapCorners()
		_dudeM = math.random(0, moneyMaxPoor)
	else
		_dudeX = math.random(mapMinX, mapMaxX)
		_dudeY = math.random(mapMinY, mapMaxY)

		if (_randomPercent < poorPercent + middlePercent) then -- middle
			_middleCount = _middleCount + 1
			_dudeM = math.random(moneyMaxPoor + 1, moneyMaxMiddle)
		else -- rich
			_richCount = _richCount + 1
			_dudeM = math.random(moneyMaxMiddle + 1, moneyMaxRich)
		end
	end
	table.insert(dudes, DudeClass.new(_dudeX, _dudeY, _dudeM))
end
print("poor/middle/rich : ", _poorCount, _middleCount, _richCount)

if (DEBUG) then
	table.insert(dudes, DudeClass.new(0,0, moneyMaxRich + 1))
end

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
