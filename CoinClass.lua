CoinClass = {}

-- STATIC ATTRIBUTES

CoinClass.nextID = 0

-- STATIC METHODS

CoinClass.getNextID = function()

	CoinClass.nextID = CoinClass.nextID + 1
	return CoinClass.nextID

end

CoinClass.createCoinBatch = function(x, y, totalValue)
	value = totalValue
	while (value > 0) do
		choice = math.random(1,coinsChoiceNumber)
		while (coinsAcceptedValue[choice] > value and choice > 1) do
			choice = choice - 1
		end
		table.insert(coins, CoinClass.new(x,y,coinsAcceptedValue[choice]))
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
		closestDude = coin:findClosestDude()

		-- Move towards him
		if (closestDude ~= nil
			and not (closestDude.invulnTimer > 0)
			and not (closestDude:class() == "rich+")
			) then

			coin.speedX = (closestDude.x - coin.x)*10
			coin.speedY = (closestDude.y - coin.y)*10
		end
	else
		coin.noCatchTimer = coin.noCatchTimer - dt
	end

	-- speed must decrease
	coin.accX = -coin.speedX
	coin.accY = -coin.speedY

	-- Speed Update
	coin.speedX = coin.speedX + coin.accX*dt
	coin.speedY = coin.speedY + coin.accY*dt
	actualSpeed = math.sqrt(coin.speedX*coin.speedX + coin.speedY*coin.speedY)
	if (actualSpeed > coinsMaxSpeed) then
		coin.speedX, coin.speedY = myVector(0, 0, coin.speedX, coin.speedY, coinsMaxSpeed)
	end

	-- Pos Update
	coin.x = coin.x + coin.speedX * dt
	coin.y = coin.y + coin.speedY * dt

	-- Caught by closest dude?
	if (closestDude ~= nil and coin.noCatchTimer <= 0 and closestDude.invulnTimer <= 0 and closestDude:class() ~= "rich+") then
		if (distance2Entities(coin, closestDude) < closestDude:dudeSize()) then
			closestDude:updateMoney(coin.value)
			coins.removeID(coin.id)
		end
	end

end

CoinClass.findClosestDude = function(coin)

	closestDude = findClosestOf(dudes, coin, coinsAttractionDistance)

	-- is player closer than the closest Dude?
	playerDistance = distance2Entities(player, coin)
	if (closestDude ~= nil)
	then closestDudeDistance = distance2Entities(closestDude, coin)
	else closestDudeDistance = playerDistance + 1
	end

	if (playerDistance < closestDudeDistance and playerDistance < coinsAttractionDistance) then
		closestDude = player
	end

	return closestDude

end

CoinClass.draw = function(coin)
	love.graphics.setColor(255,255,0)
	coinRadius = math.max(1, coin.value/coinsValuePerPx)
	if (coin.lifeTime < coinsFadeTime) then
		fadeFactor = coin.lifeTime/coinsFadeTime
		coinRadius = math.max(1, coinRadius*fadeFactor)
		love.graphics.setColor(255*fadeFactor, 255*fadeFactor, 0)
	end
	if (coin.noCatchTimer > 0) then
		fillage = "line"
	else
		fillage = "fill"
	end
	love.graphics.circle(fillage, coin.x, coin.y, coinRadius, coinRadius*4)

	if (DEBUG) then
		love.graphics.print(coin.id, coin.x+5, coin.y)
		closestDude = coin:findClosestDude()
		if (closestDude ~= nil) then
			love.graphics.line(coin.x,coin.y,closestDude.x, closestDude.y)
		end
	end
end

-------------------------------------------------------------------

CoinClass.new = function(x,y,value)
	coin = {}
	setmetatable(coin, {__index = CoinClass})

	coin.id = CoinClass.getNextID()
	coin.x = x
	coin.y = y
	coin.value = value
	-- Random direction
	coin.speedX = math.random(coinsMinRandSpeedX, coinsMaxRandSpeedX)
	coin.speedY = math.random(coinsMinRandSpeedY, coinsMaxRandSpeedY)
	coin.accX = - coin.speedX
	coin.accY = - coin.speedY
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
