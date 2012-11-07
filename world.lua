world = {}

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
	local _offsetX = -player.x + wScr/2
	local _offsetY = -player.y + hScr/2

	-- playerSpeed = math.sqrt(player.speedX^2 + player.speedY^2)
	-- scaleFactor = 1 - (playerSpeed / playerMaxSpeed) / 10 -- the idea was that the "camera" zoomed out while the player speed went up, but this doesn't work (probably because of floating points or something)
	local _scaleFactor = 1
	love.graphics.scale(_scaleFactor, _scaleFactor)
	love.graphics.translate(_offsetX*_scaleFactor, _offsetY*_scaleFactor)

	-- draw map grid
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


	for dudeN,dude in ipairs(dudes) do
		dude:draw()
	end

	for coinN, coin in ipairs(coins) do
		coin:draw()
	end

	for fbN, fb in ipairs(fireballs) do
		fb:draw()
	end

	player.draw()

	love.graphics.translate(-_offsetX*_scaleFactor,-_offsetY*_scaleFactor)
	love.graphics.scale(1/_scaleFactor, 1/_scaleFactor)
end

world.keypressed = function(k)
	player.keypressed(k)
end