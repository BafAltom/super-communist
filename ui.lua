ui = {}
ui.minimapCanvas = love.graphics.newCanvas(minimapHeight, minimapLength)
ui.minimapCanvas:clear(0,0,0)

ui.update = function(dt)

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
	love.graphics.setColor(0,0,0)

	-- miniMap
	love.graphics.setCanvas(ui.minimapCanvas)
	ui.minimapCanvas:clear(0,0,0)

	-- outline of subMap

	love.graphics.setColor(100,100,100)
	lineWidthStored = love.graphics.getLineWidth()
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", (mapMinX - subMapMinX)/ minimapXfactor, (mapMinY - subMapMinY) / minimapYfactor, (mapMaxX - mapMinX) / minimapXfactor, (mapMaxY - mapMinY) / minimapYfactor)
	love.graphics.setLineWidth(lineWidthStored)

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
	love.graphics.setCanvas()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(ui.minimapCanvas, minimapX, minimapY)


end
