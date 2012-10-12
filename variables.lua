	wScr = love.graphics.getWidth()
	hScr = love.graphics.getHeight()
	xOffset = 0
	yOffset = 0
	DEBUG = false
	PAUSE = true

--[[ RESSOURCES
	picPoor = love.graphics.newImage("res/poor.png")
	picMiddle = love.graphics.newImage("res/middle.png")
	picRich = love.graphics.newImage("res/rich.png")
	picRichPlus = love.graphics.newImage("res/richPlus.png")
	--]]
	dudeGrid = anim8.newGrid(32,64,32,256)
	-- default : anim8.newAnimation("loop", dudeGrid('1,1-4'), 0.3)

	picPoorIdle = love.graphics.newImage("poor_idle.png")
	picPoorWalking = love.graphics.newImage("poor_walking.png")
	picPoorRunning = love.graphics.newImage("poor_running.png")
	picPoorMoney = love.graphics.newImage("poor_moneyPursuing.png")
	picMiddleIdle = love.graphics.newImage("middle_idle.png")
	picMiddleWalking = love.graphics.newImage("middle_walking.png")
	picMiddleRunning = love.graphics.newImage("middle_running.png")
	picMiddleMoney = love.graphics.newImage("middle_moneyPursuing.png")
	picRichIdle = love.graphics.newImage("rich_idle.png")
	picRichWalking = love.graphics.newImage("rich_walking.png")
	picRichRunning = love.graphics.newImage("rich_running.png")
	picRichMoney = love.graphics.newImage("rich_moneyPursuing.png")
	picHeartFull = love.graphics.newImage("heart_full.png")
	picHeartEmpty = love.graphics.newImage("heart_empty.png")

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
	playerLives = 3
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
	dudeMoneyTimer = 2
	dudeMoneyFade = 0.3 --s
	superRichHitDistance = 150
	richHitTimer = 2.5
	invulnTimeByHit = 6
	invulnTimeByClassChange = 1
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
	totalMoney = numberOfDudes*(moneyMaxPoor+moneyMaxMiddle)/2 -- not used right now TODO
	poorPercent = 30
	middlePercent = 40
	richPercent = 30

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

	fireballSpeed = 70
	fireBallAttackTimer = 0.1
	fireballLifeTime = 1.5
	fireballFadeTimer = 0.5

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