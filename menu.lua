menu = {}

function menu.update(dt)
end

function menu.draw()
	love.graphics.print("MENU\nPress enter to play",wScr/2, hScr/2)
end

function menu.keypressed(k)
	if (k == "return") then
		displayMenu = false
	end
end
