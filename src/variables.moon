export *

wScr = love.graphics.getWidth()
hScr = love.graphics.getHeight()
xOffset = 0
yOffset = 0
DEBUG = false
PAUSE = true

-- RESSOURCES
picHeartFull = love.graphics.newImage("res/heart_full.png")
picHeartEmpty = love.graphics.newImage("res/heart_empty.png")
picItemPlaceHolder = love.graphics.newImage("res/item_placeholder.png")

-- MAPS CONSTANTS
mapSize = 600
subMapSize = 1000

mapMaxX = mapSize
mapMinX = -mapSize
mapMaxY = mapSize
mapMinY = -mapSize
-- subMap should be bigger than normal map
subMapMaxX = subMapSize
subMapMinX = -subMapSize
subMapMaxY = subMapSize
subMapMinY = -subMapSize

-- PLAYER CONSTANTS
playerSize = 20
playerMaxSpeed = 300 -- px/s
playerSpeedKeyDownIncrease = 300 --px/s^2
playerSpeedKeyUpDecrease = 600 -- px/s^2
playerLives = 3
playerMaxMoney = 3000
playerWeaponRadiusSpeed = 60
playerWeaponRadiusMax = 100
playerMegaDropAmount = 100
playerMiniDropAmount = 30
playerInvulnTimeByHit = 0.5
playerCorruptionSpeedFactor = 0.25
playerCorruptionLeakTimer = 1
playerCorruptionLeakValue = 50

-- DUDES CONSTANTS
numberOfDudes = 100
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
-- moneyMaxPoor * numberOfDudes < x < moneyMaxMiddle * numberOfDudes
-- So the total number of money should be
--  numberOfDudes * (moneyMaxPoor + moneyMaxMiddle) / 2
totalMoney = numberOfDudes * (moneyMaxPoor + moneyMaxMiddle) / 2 -- TODO use this
poorPercent = 30
middlePercent = 40
richPercent = 30

poorColor = {153 / 255, 99 / 255, 67 / 255}
middleColor = {139 / 255, 200 / 255, 130 / 255}
richColor = {1, 0, 0}
richPlusColor = {1, 1, 1}

-- COINS CONSTANTS
coinsValuePerPx = 5
coinsMaxSpeed = 75
coinsAcceptedValue = {1, 10, 20} -- increasing order, smallest value must be "1"
coinsChoiceNumber = #coinsAcceptedValue
coinsAttractionDistance = 50
coinsCatchDistance = 10
coinsNoCatchTime = 0.5
coinsLifeTime = 60
coinsFadeTime = 1

-- FIREBALL CONSTANTS

fireballSpeed = 70
fireBallAttackTimer = 0.1
fireballLifeTime = 2.5
fireballFadeTimer = 0.5

-- GRID CONSTANTS

gridRows = 5
gridColumns = 5

-- MENU CONSTANTS
-- MONEYBAR
moneyBarX = 10
moneyBarY = 10
moneyBar_moneyByPx = 5
moneyBarLength = playerMaxMoney / moneyBar_moneyByPx
moneyBarHeight = 20
--MINIMAP
minimapX = wScr - 160
minimapY = hScr - 160
minimapLength = 150
minimapHeight = 150
minimapXfactor = (subMapMaxX - subMapMinX) / minimapLength
minimapYfactor = (subMapMaxY - subMapMinY) / minimapHeight

-- SHOP CONSTANTS
shopRectangle = {0, hScr / 5, 4 * wScr / 5, 3 * hScr / 4}
shopItemSize = {150, 150}
shopItemMargin = 10
shopFadeTime = 0.5
shopItemPerRow = math.floor shopRectangle[3] / (shopItemSize[1] + shopItemMargin)

