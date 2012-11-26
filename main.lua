--[[

SUPER CÖMMUNIST
A game by Altom for the March 2012 Experimental Gameplay Project (Theme: ECONOMY)

Begun : Sunday March 4th (supposed worktime: 7 days, delay: still counting)

RANDOM IDEAS:
- "Godly events" : Economy crash, Oil pit, Technology : try to rebalance the economy inline
- Shop : for heart containers and "communist-like" power-ups (shield for poor, )
]]--


function love.load()
	local _seed
	if (DEBUG) then
		_seed = "I think it's better to have deterministic tests"
	else
		_seed = os.time()
	end
	math.randomseed(_seed)
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
	require "world"
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
		world:draw()
		ui:draw()

		-- WIN
		if (dudes.areAllMiddle()) then
			menu.setState("won")
			displayMenu = true
		end

		-- LOOSE
		if (player.life <= 0) then
			menu.setState("lost")
			PAUSE = true
			displayMenu = true
		end
	end
end

function love.update(dt)
	if (not PAUSE and not displayMenu) then
		world.update(dt)
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
			menu.setState("pause")
			PAUSE = true
			displayMenu = true
		else
			world.keypressed(k)
			ui.keypressed(k)
		end
	end
end
