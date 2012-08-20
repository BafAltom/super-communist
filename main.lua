--[[

SUPER CÖMMUNIST
A game by Altom for the March 2012 Experimental Gameplay Project (Theme: ECONOMY)

Begun : Sunday March 4th (supposed delay: 7 days)

TODO:
- "attract the poor" button
- coherent corruption effect (fat sprite, cannot attract poor, cannot pick coins up, cannot attack, must go under threshold to regain uncorrupted state)

RANDOM IDEAS:
- rich+ indicator (point to it on the edge of the screen, L4D2/Portal2-like)
- short invulnerability during class transformation
]]--


function love.load()
	if (DEBUG) then
		seed = "I think it's better to have deterministic tests"
	else
		seed = os.time()
	end
	math.randomseed(seed)
	math.random();math.random();math.random()
	love.mouse.setVisible(false)

	-- External libraries
	anim8 = require "anim8"

	-- custom libraries
	require "variables"
	require "menu"
	require "DudeClass"
	require "CoinClass"
	require "FireBallClass"
	require "ui"
	require "player"
	require "bafaltom2D"
	-- Note : each class handle its initialization

	displayMenu = true

end

function love.draw()
	if (displayMenu) then
		menu.draw()
	else
		local _offsetX = -player.x + wScr/2
		local _offsetY = -player.y + hScr/2

		-- playerSpeed = math.sqrt(player.speedX^2 + player.speedY^2)
		-- scaleFactor = 1 - (playerSpeed / playerMaxSpeed) / 10 -- the idea was that the "camera" zoomed out while the player speed went up, but this doesn't work (probably because of floating points)
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

		ui:draw()

		-- WIN
		if (dudes.allMiddle()) then
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("fill", 0,0,wScr,hScr)
			love.graphics.setColor(255,255,255)
			love.graphics.print("YOU WIN", wScr/2, hScr/2)
		end

		-- LOOSE
		if (player.life <= 0) then
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("fill", 0,0,wScr,hScr)
			love.graphics.setColor(255,255,255)
			love.graphics.print("YOU LOOSE", wScr/2, hScr/2)
		end

		-- PAUSE
		if (PAUSE) then
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("fill", wScr/2-22, hScr/2-15, 44, 30)
			love.graphics.setColor(255,255,255)
			love.graphics.print("PAUSE", wScr/2- 20, hScr/2)
		end
	end

	-- FPS
	if (true) then -- if(DEBUG) ?
		love.graphics.setColor(255,255,255)
		love.graphics.print("FPS : "..love.timer.getFPS(), wScr-100, 10)
	end

end

function love.update(dt)

	if (not PAUSE) then
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

end

function love.keypressed(k)
	if (displayMenu) then
		menu.keypressed(k)
	else
		-- player actions must be in player.keypressed (in player.lua)
		if (k == "o") then
			DEBUG = not DEBUG
		elseif (k == "p") then
			PAUSE = not PAUSE
		elseif (k == "escape") then
			love.event.push("quit")
		else
			player.keypressed(k)
			ui.keypressed(k)
		end
	end
end
