world = {}

world.offsetX = 0
world.offsetY = 0
world.scaleFactor = 1

world.update = function(dt)
	player.update(dt)
	ui.update(dt)
	for dudeN,dude in ipairs(dudes) do
		dude:update(dt)
	end

	for coinN,coin in ipairs(coins) do
		coin:update(dt)
	end

	for fbN,fb in ipairs(fireballs) do
		fb:update(dt)
	end

end

world.draw = function()
	world.translateAxes()

	world.drawMapGrid()

	for dudeN,dude in ipairs(dudes) do
		dude:draw()
	end

	local _richesPlus = dudes.getAllRichPlus()
	for rdN, rd in ipairs(_richesPlus) do
		if (not world.isEntityInScreen(rd, 0)) then
			local _richPlusDirX, _richPlusDirY = myVector(player.x, player.y, rd.x, rd.y, 50)
			love.graphics.setColor(255,255,255)
			love.graphics.line(player.x, player.y, player.x + _richPlusDirX, player.y + _richPlusDirY)
		end
	end

	for coinN, coin in ipairs(coins) do
		coin:draw()
	end

	for fbN, fb in ipairs(fireballs) do
		fb:draw()
	end

	player.draw()

	world.inverseTranslateAxes()
end

world.keypressed = function(k)
	player.keypressed(k)
end

world.drawMapGrid = function()
	-- suburbs
	love.graphics.setColor(20,10,10)
	love.graphics.rectangle("fill", subMapMinX, subMapMinY, subMapMaxX - subMapMinX, subMapMaxY - subMapMinY)

	-- maps
	love.graphics.setColor(10,20,10)
	love.graphics.rectangle("fill", mapMinX, mapMinY, mapMaxX - mapMinX, mapMaxY - mapMinY)

	-- columns
	love.graphics.setColor(100,100,100)
	for i=0,gridColumns do
		love.graphics.line((i*(mapMaxX-mapMinX)/gridColumns+mapMinX), mapMinY, (i*(mapMaxX-mapMinX)/gridColumns+mapMinX), mapMaxY)
	end
	-- rows
	for i=0,gridRows do
		love.graphics.line(mapMinX, (i*(mapMaxY-mapMinY)/gridRows+mapMinY), mapMaxX, (i*(mapMaxY-mapMinY)/gridRows+mapMinY))
	end
end

world.translateAxes = function()
	world.offsetX = -player.x + wScr/2
	world.offsetY = -player.y + hScr/2

	-- local _playerSpeed = math.sqrt(player.speedX^2 + player.speedY^2)
	-- world.scaleFactor = 1 - (_playerSpeed / playerMaxSpeed) / 10 -- the idea was that the "camera" zoomed out while the player speed went up, but this doesn't work (probably because of floating points or something)
	world.scaleFactor = 1
	love.graphics.scale(world.scaleFactor, world.scaleFactor)
	love.graphics.translate(world.offsetX * world.scaleFactor, world.offsetY * world.scaleFactor)
end

world.inverseTranslateAxes = function()
	love.graphics.translate(-world.offsetX * world.scaleFactor, -world.offsetY * world.scaleFactor)
	love.graphics.scale(1/world.scaleFactor, 1/world.scaleFactor)
end

world.isEntityInScreen = function(entity, tolerance)
--tolerance : allow the entity to be outside (> 0) or inside (< 0) the screen by that amount of pixels
	local _outByX = math.abs(entity.x - player.x) > wScr/2 + tolerance
	local _outByY = math.abs(entity.y - player.y) > hScr/2 + tolerance
	return not (_outByX or _outByY)
end