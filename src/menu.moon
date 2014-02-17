class Menu
    new: (@textDict, initialState) =>
        @state = initialState

    update: (dt) =>

    draw: =>
        love.graphics.setColor 255, 255, 255,255
        love.graphics.print @textDict[@state], wScr / 2, hScr / 2
        love.graphics.print "Press enter to start a new game", wScr / 2, hScr / 2 + 10
        if @state == "pause"
            love.graphics.print "Press space to resume", wScr / 2, hScr / 2 + 20
        love.graphics.print "Press esc to quit", wScr/2, hScr/2 + 50

    keypressed: (k) =>
        switch k
            when "return"
                @restart_game!
                displayMenu = false
                PAUSE = false
            when " "
                displayMenu = false
                PAUSE = false
            when "escape"
                love.event.push("quit")

    restart_game: =>
        shop:initialize()
        dudes.initialize()
        player.initialize()


dict = {
    mainmenu: "SUPER-COMMUNIST - THE GAME"
    pause: "THE GAME IS PAUSED"
    lost: "YOU JUST LOST"
    won: "YOU JUST WON"
}

export menu = Menu dict, "mainmenu"
