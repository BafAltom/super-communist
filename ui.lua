ui = {}
ui.displayHelp = false
ui.helpHiddenText = "press H to display help"
ui.helpText = "Use WASD or ZSQD to move (both work)\nUse the Spacebar to attack (you'll figure it out)\nPress Shift to drop money and e to drop less money\nYour Goal : Remove all inegalities!\nGood Luck!\n\nPress h to hide this text"
ui.displayMinimap = true
ui.displayShop = false

ui.update = function(dt)

end

ui.keypressed = function(k)
	if (k == "h") then
		ui.displayHelp = not ui.displayHelp
	end
end

ui.draw = function()

	-- rich+ indicator
	local _richesPlus = dudes.getAllRichPlus()
	for rdN, rd in ipairs(_richesPlus) do
		if (not world.isEntityInScreen(rd, 0)) then
			local _richPlusDirX, _richPlusDirY = myVector(player.x, player.y, rd.x, rd.y, 50)
			love.graphics.setColor(255,255,255)
			local _d = player.dudeSize()*2
			love.graphics.circle("line", wScr/2, hScr/2, _d)
			local _cos = (rd.y - player.y) / (1.0*distance2Entities(player, rd))
			local _sin = (rd.x - player.x) / (1.0*distance2Entities(player, rd))
			local _indicX = wScr/2 + _sin*_d
			local _indicY = hScr/2 + _cos*_d
			love.graphics.line(_indicX, _indicY, _indicX + _richPlusDirX, _indicY + _richPlusDirY)
		end
	end

	-- money bar
	local barLength = math.min(moneyBarLength-2, player.money/moneyBar_moneyByPx)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", moneyBarX, moneyBarY, moneyBarLength, moneyBarHeight)
	love.graphics.setColor(255,255,0)
	love.graphics.rectangle("fill", moneyBarX+1, moneyBarY+1, barLength, moneyBarHeight-2)
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", moneyBarX+1 + barLength, moneyBarY+1, moneyBarLength-2-barLength, moneyBarHeight-2)

	-- health
	local _pic, _alpha
	for i=1,playerLives do
		if (i <= player.life) then
			_pic = picHeartFull
			_alpha = 255
		else
			_pic = picHeartEmpty
			_alpha = 100
		end
		love.graphics.setColor(255,255,255, _alpha)
		love.graphics.draw(_pic, moneyBarLength + i*30, moneyBarY)
	end

	if (ui.displayMinimap) then
		ui.drawMinimap()

	-- FPS
	if (true) then -- if(DEBUG) ?
		love.graphics.setColor(255,255,255)
		love.graphics.print("FPS : "..love.timer.getFPS(), wScr-100, 10)
	end

	end

	-- help
	local helpText
	if (not ui.displayHelp) then
		helpText = ui.helpHiddenText
	else
		helpText = ui.helpText
	end
	love.graphics.print(helpText, moneyBarX, moneyBarY + 50)
end

ui.drawMinimap = function()
	love.graphics.translate(minimapX, minimapY)
	love.graphics.setColor(20,10,10)
	love.graphics.rectangle("fill", 0,0, minimapLength, minimapHeight)
	love.graphics.setColor(10,20,10)
	love.graphics.rectangle("fill", (mapMinX - subMapMinX)/ minimapXfactor, (mapMinY - subMapMinY) / minimapYfactor, (mapMaxX - mapMinX) / minimapXfactor, (mapMaxY - mapMinY) / minimapYfactor)
	-- small optimization (or is it?)
	local minimapXfactor, minimapYfactor = minimapXfactor, minimapYfactor

	-- outlines
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line", 0,0, minimapLength, minimapHeight)
	love.graphics.setColor(100,100,100)
	love.graphics.rectangle("line", (mapMinX - subMapMinX)/ minimapXfactor, (mapMinY - subMapMinY) / minimapYfactor, (mapMaxX - mapMinX) / minimapXfactor, (mapMaxY - mapMinY) / minimapYfactor)

	-- all the dudes
	for _, d in ipairs(dudes) do
		local miniSize, miniColors
		if (d:class() == "poor") then
			miniColors = poorColor
			miniSize = 3
		elseif (d:class() == "middle") then
			miniColors = middleColor
			miniSize = 1
		elseif (d:class() == "rich") then
			miniColors = richColor
			miniSize = 3
		elseif (d:class() == "rich+") then
			miniColors = richPlusColor
			miniSize = 5
		end

		love.graphics.setColor(miniColors)
		love.graphics.rectangle("fill", minimapLength/2 + d.x/minimapXfactor, minimapHeight/2 + d.y/minimapYfactor, miniSize, miniSize)
	end
	-- player
	love.graphics.setColor(0,255,255)
	love.graphics.rectangle("fill", minimapLength/2 + player.x/minimapXfactor, minimapHeight/2 + player.y/minimapYfactor, 4, 4)
	love.graphics.translate(-minimapX, -minimapY)
	love.graphics.setColor(255,255,255)
end