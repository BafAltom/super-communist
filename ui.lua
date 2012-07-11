ui = {}
ui.displayHelp = false
ui.displayMinimap = true

ui.update = function(dt)

end

ui.keypressed = function(k)
	if (k == "h") then
		ui.displayHelp = not ui.displayHelp
	end
end

ui.draw = function()
	-- money bar
	barLength = math.min(moneyBarLength-2, player.money/moneyBar_moneyByPx)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", moneyBarX, moneyBarY, moneyBarLength, moneyBarHeight)
	love.graphics.setColor(255,255,0)
	love.graphics.rectangle("fill", moneyBarX+1, moneyBarY+1, barLength, moneyBarHeight-2)
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", moneyBarX+1 + barLength, moneyBarY+1, moneyBarLength-2-barLength, moneyBarHeight-2)

	-- health
	love.graphics.setColor(255,0,0)
	for i=1,3 do
		if (i <= player.life) then
			fillage = "fill"
		else
			fillage = "line"
		end
		love.graphics.circle(fillage, moneyBarLength + i*30, moneyBarY + 10, 10, 15)
	end

	if (ui.displayMinimap) then
		love.graphics.translate(minimapX, minimapY)
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill", 0,0, minimapLength, minimapHeight)

		-- outline of subMap in miniMap

		love.graphics.setColor(100,100,100)
		love.graphics.rectangle("line", (mapMinX - subMapMinX)/ minimapXfactor, (mapMinY - subMapMinY) / minimapYfactor, (mapMaxX - mapMinX) / minimapXfactor, (mapMaxY - mapMinY) / minimapYfactor)

		-- all the dudes
		for _, d in ipairs(dudes) do
			if (d:class() == "poor") then
				love.graphics.setColor(255,0,0)
				miniSize = 1
			elseif (d:class() == "middle") then
				love.graphics.setColor(0,255,0)
				miniSize = 2
			elseif (d:class() == "rich") then
				love.graphics.setColor(0,0,255)
				miniSize = 2
			elseif (d:class() == "rich+") then
				love.graphics.setColor(255,255,255)
				miniSize = 3
			end

			love.graphics.rectangle("fill", minimapLength/2 + d.x/minimapXfactor, minimapHeight/2 + d.y/minimapYfactor, miniSize, miniSize)
		end
		-- player
		love.graphics.setColor(0,255,255)
		love.graphics.rectangle("fill", minimapLength/2 + player.x/minimapXfactor, minimapHeight/2 + player.y/minimapYfactor, 4, 4)
		love.graphics.translate(-minimapX, -minimapY)
		love.graphics.setColor(255,255,255)
	end

	-- help
	if (not ui.displayHelp) then
		helpText = "press H to display help"
	else
		helpText =
			"Use WASD or ZSQD to move (both work)\nPress, hold and release the Spacebar to attack (you'll figure it out)\nPress Shift to drop money\nRed/Green/Blue squares are poor/average/rich dudes\nWhite squares are billionaire dudes, they do not like you\nYour Goal : make everyone average\nGood Luck!\nPress h to hide this text"
	end
	love.graphics.print(helpText, moneyBarX, moneyBarY + 50)
end
