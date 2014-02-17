CoinClass = {}

-- STATIC ATTRIBUTES

CoinClass.nextID = 0

-- STATIC METHODS

CoinClass.getNextID = function()

	CoinClass.nextID = CoinClass.nextID + 1
	return CoinClass.nextID

end

CoinClass.normalizeSpeed = function(coin, speed)
	coin.speedX, coin.speedY = bafaltomVector(0, 0, coin.speedX, coin.speedY, speed)
end

CoinClass.createCoinBatch = function(x, y, totalValue)
	CoinClass.createCoinBatchWithDirection(x, y, totalValue, 0, 0)
end

CoinClass.createCoinBatchWithDirection = function(x, y, totalValue, vx, vy)
	value = totalValue
	while (value > 0) do
		choice = math.random(1,coinsChoiceNumber)
		while (coinsAcceptedValue[choice] > value and choice > 1) do
			choice = choice - 1
		end
		table.insert(coins, CoinClass.new(x,y,coinsAcceptedValue[choice], vx, vy))
		value = value - coinsAcceptedValue[choice]
	end
end

-- CLASS METHODS

CoinClass.update = function(coin, dt)
	coin.lifeTime = coin.lifeTime - dt

	if (coin.lifeTime < 0) then
		coins.removeID(coin.id)
	end

	if (coin.noCatchTimer <= 0) then
		-- Find closest Dude (or player)
		_closestDude = coin:findClosestDude()

		-- Move towards him
		if (_closestDude ~= nil
			and not (_closestDude.invulnTimer > 0)
			and not (_closestDude:class() == "rich+")
			) then

			-- magic numbers
			coin.accX = (_closestDude.x - coin.x)*20
			coin.accY = (_closestDude.y - coin.y)*20
		else
			coin.accX = -coin.speedX
			coin.accY = -coin.speedY
		end

		-- Caught by him?
		if (_closestDude ~= nil and coin.noCatchTimer <= 0 and _closestDude.invulnTimer <= 0 and _closestDude:class() ~= "rich+") then
			if (distance2Entities(coin, _closestDude) < _closestDude:dudeSize()) then
				_closestDude:updateMoney(coin.value)
				coins.removeID(coin.id)
			end
		end
	else
		coin.noCatchTimer = coin.noCatchTimer - dt
	end

	-- Speed Update
	coin.speedX = coin.speedX + coin.accX*dt
	coin.speedY = coin.speedY + coin.accY*dt
	local _actualSpeed = math.sqrt(coin.speedX*coin.speedX + coin.speedY*coin.speedY)
	if (_actualSpeed > coinsMaxSpeed) then
		coin.speedX, coin.speedY = bafaltomVector(0, 0, coin.speedX, coin.speedY, coinsMaxSpeed)
	end

	-- Pos Update
	coin.x = coin.x + coin.speedX * dt
	coin.y = coin.y + coin.speedY * dt
end

CoinClass.findClosestDude = function(coin)

	local _filteredDudes = {} -- dudes which can attract coins
	for _,d in ipairs(dudes) do
		if (d:class() ~= "rich+" and d.invulnTimer <= 0) then
			table.insert(_filteredDudes, d)
		end
	end
	-- add player to the table, except if he's corrupted
	if (not player.corrupted) then
		table.insert(_filteredDudes, player)
	end

	local _closestDude = findClosestOf(_filteredDudes, coin, coinsAttractionDistance)

	return _closestDude

end

CoinClass.draw = function(coin) -- TODO clean up a bit?
	love.graphics.setColor(255,255,0)
	local _coinRadius = math.max(1, coin.value/coinsValuePerPx)
	if (coin.lifeTime < coinsFadeTime) then
		local _fadeFactor = coin.lifeTime/coinsFadeTime
		_coinRadius = math.max(1, _coinRadius*_fadeFactor)
		love.graphics.setColor(255*_fadeFactor, 255*_fadeFactor, 0)
	end
	local fillage
	if (coin.noCatchTimer > 0) then
		_fillage = "line"
	else
		_fillage = "fill"
	end
	love.graphics.circle(_fillage, coin.x, coin.y, _coinRadius, _coinRadius*4)

	if (DEBUG) then
		love.graphics.print(coin.id, coin.x+5, coin.y)
		local _closestDude = coin:findClosestDude()
		if (_closestDude ~= nil) then
			love.graphics.line(coin.x,coin.y,_closestDude.x, _closestDude.y)
		end
	end
end

CoinClass.getX = function(coin)
	return coin.x
end

CoinClass.getY = function(coin)
	return coin.y
end

-------------------------------------------------------------------

CoinClass.new = function(x,y,value,sx,sy)
	local coin = {}
	setmetatable(coin, {__index = CoinClass})

	coin.id = CoinClass.getNextID()
	coin.x = x
	coin.y = y
	coin.value = value
	if (sx ~= 0 and sy ~= 0) then
		-- need refactoring :(
		if (sx > 0) then
			coin.speedX = math.random(0, sx*10)
		else
			coin.speedX = math.random(sx*10, 0)
		end
		if (sy > 0) then
			coin.speedY = math.random(0, sy*10)
		else
			coin.speedY = math.random(sy*10, 0)
		end
	else -- Random direction
		coin.speedX = math.random(-100, 100)/100
		coin.speedY = math.random(-100, 100)/100
	end
	coin:normalizeSpeed(math.random(coinsMaxSpeed*0.5, coinsMaxSpeed))
	coin.accX = 0
	coin.accY = 0
	coin.noCatchTimer = coinsNoCatchTime
	coin.lifeTime = coinsLifeTime

	return coin
end

---------------------------------------------------------------

coins = {}

coins.getID = function(id)
	for _, c in ipairs(coins) do
		if (c.id == id) then
			return c
		end
	end
	return nil
end

coins.removeID = function(id)
	for n,c in ipairs(coins) do
		if(c.id == id) then
			table.remove(coins, n)
			return
		end
	end
end