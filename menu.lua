menu = {}
menu.state = "mainmenu"
menu.acceptedStates = {"mainmenu", "pause", "lost", "won"}

menu.text = {mainmenu = "SUPER-COMMUNIST - THE GAME"; pause = "THE GAME IS PAUSED"; lost = "YOU JUST LOST"; won = "YOU JUST WON"}

function menu.setState(newState)
	for _,s in ipairs(menu.acceptedStates) do
		if (newState == s) then
			menu.state = newState
			return
		end
	end
	error('menu.setState(newState) : newState = '..newState..' was not in accepted states')
end

function menu.update(dt)
end

function menu.draw()
	love.graphics.print(menu.text[menu.state], wScr/2, hScr/2)
	love.graphics.print("Press enter to start a new game", wScr/2, hScr/2+10)
	if (menu.state == "pause") then love.graphics.print("Press space to resume", wScr/2, hScr/2+20) end
	love.graphics.print("Press esc to quit", wScr/2, hScr/2+50)
end

function menu.keypressed(k)
	if (k == "return") then
		menu.restart_game()
		displayMenu = false
		PAUSE = false
	elseif (k==" ") then
		displayMenu = false
		PAUSE = false
	elseif (k=="escape") then
		love.event.push("quit")
	end
end

function menu.restart_game()
	dudes.initialize()
	player.initialize()
end