	wScr = love.graphics.getWidth()
	hScr = love.graphics.getHeight()
	xOffset = 0
	yOffset = 0
	DEBUG = false
	PAUSE = false

--[[ RESSOURCES
	picPoor = love.graphics.newImage("res/poor.png")
	picMiddle = love.graphics.newImage("res/middle.png")
	picRich = love.graphics.newImage("res/rich.png")
	picRichPlus = love.graphics.newImage("res/richPlus.png")
	--]]

-- MAPS CONSTANTS
	-- TODO : Change all of those with two variables "mapSize" and "subMapSize" (easier)
	mapMaxX = 600
	mapMinX = -600
	mapMaxY = 600
	mapMinY = -600
	-- subMap should be bigger than normal map
	subMapMaxX = 1000
	subMapMinX = -1000
	subMapMaxY = 1000
	subMapMinY = -1000
	function isInSubMap(x,y)	return (x < mapMinX or x > mapMaxX or y < mapMinY or y > mapMaxY) end
	function randomPointInSubMapCorners()
		isDown = math.random(0,1) -- up/down?
		isRight = math.random(0,1) -- left/right?
		cornerX = math.random(0, subMapMaxX - mapMaxX)
		cornerY = math.random(0, subMapMaxY - mapMaxY)

		return (-subMapMaxX + isRight*(subMapMaxX + mapMaxX) + cornerX), (-subMapMaxY + isDown*(subMapMaxY + mapMaxY) + cornerY)

	end

-- PLAYER CONSTANTS
	playerSize = 10
	playerMaxSpeed = 300 -- px/s
	playerSpeedKeyDownIncrease = 300 --px/s^2
	playerSpeedKeyUpDecrease = 600 -- px/s^2
	playerMaxMoney = 2000
	playerWeaponRadiusSpeed = 60
	playerWeaponRadiusMax = 100
	playerNumberOfCoinsByDrop = 100
	playerInvulnTimeByHit = 0.5
	playerCorruptionSpeedFactor = 0.25

-- DUDES CONSTANTS
	numberOfDudes = 60
	dudeMaxSpeed = 20
	destAcceptanceRadius = 10
	dudeNextDestRadius = 50
	dudeNextDestWaitTimeMin = 1
	dudeNextDestWaitTimeMax = 3
	moneyMaxPoor = 50
	moneyMaxMiddle = 200
	moneyMaxRich = 400
	moneyRadiusFactor = 0.3
	moneyStolenByHit = 10
	superRichHitDistance = 100
	richHitTimer = 2.5
	invulnTimeByHit = 6
	fleeMinX = mapMinX
	fleeMaxX = mapMaxX
	fleeMinY = mapMinY
	fleeMaxY = mapMaxY
	dudeAttractionDistance = 200
	richPlusStalkDistance = 100

	-- let's try to make the system stable
	-- we want everyone to be middle eventually
	-- so if x is the total number of money, we have :
	-- moneyMaxPoor*numberOfDudes < x < moneyMaxMiddle*numberOfDudes
	-- Let's say (numberOfDudes*(moneyMaxPoor+moneyMaxMiddle)/2)
	totalMoney = numberOfDudes*(moneyMaxPoor+moneyMaxMiddle)/2
	poorPercent = 30
	middlePercent = 50
	richPercent = 20

-- COINS CONSTANTS
	coinsValuePerPx = 5
	coinsMinRandSpeedX = -200
	coinsMaxRandSpeedX = 200
	coinsMinRandSpeedY = -200
	coinsMaxRandSpeedY = 200
	coinsMaxSpeed = 50
	coinsAcceptedValue = {1,5,10,20}
	coinsChoiceNumber = #coinsAcceptedValue
	coinsAttractionDistance = 100
	coinsCatchDistance = 10
	coinsNoCatchTime = 1
	coinsLifeTime = 10
	coinsFadeTime = 1

-- FIREBALL CONSTANTS

	fireballSpeed = 30
	fireBallAttackTimer = 1
	fireballLifeTime = 5

-- GRID CONSTANTS

	gridRows = 5
	gridColumns = 5

-- MENU CONSTANTS
	-- MONEYBAR
	moneyBarX = 10
	moneyBarY = 10
	moneyBar_moneyByPx = 4
	moneyBarLength = playerMaxMoney/moneyBar_moneyByPx
	moneyBarHeight = 20
	--MINIMAP
	minimapX = wScr - 160
	minimapY = hScr - 160
	minimapLength = 150
	minimapHeight = 150
	minimapXfactor = (subMapMaxX - subMapMinX)/minimapLength
	minimapYfactor = (subMapMaxY - subMapMinY)/minimapHeight

-- FUNCTIONS
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
		local currentNorm = distance2Points(startX, startY, endX, endY)
		local normFactor = desiredNorm / currentNorm
		local dx = endX - startX
		local dy = endY - startY
		return dx*normFactor, dy*normFactor
	end
