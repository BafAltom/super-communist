export ^

class UI
    new: =>
        @displayHelp = false
        @helpHiddenText = "press H to display help"
        @helpText = "Use WASD or ZSQD to move (both work)\nUse the Spacebar to attack (you'll figure it out)\nPress Shift to drop money and e to drop less money\nYour Goal : Remove all inequalities!\nGood Luck!\n\nPress h to hide this text"
        @displayMinimap = true
        @displayShop = false

    update: (dt) =>

    keypressed: (k) =>
        switch k
            when "h"
                @displayHelp = not @displayHelp

    draw: =>
        -- rich+ indicator
        richesPlus = dudeList\getAllRichPlus!

        for rd in *richesPlus
            if not world\isEntityInScreen(rd, 0)
                richPlusDirX, richPlusDirY = bafaltomVector player.x, player.y,
                    rd\getX!, rd\getY!, 50
                love.graphics.setColor 255, 255, 255
                d = player\dudeSize! * 2
                love.graphics.circle "line", wScr / 2, hScr / 2, d
                cos = (rd.y - player.y) / distance2Entities(player, rd)
                sin = (rd.x - player.x) / distance2Entities(player, rd)
                indicX = wScr / 2 + sin * d
                indicY = hScr / 2 + cos * d
                love.graphics.line indicX, indicY,
                    indicX + richPlusDirX, indicY + richPlusDirY

        -- money bar
        barLength = math.min moneyBarLength - 2, player.money / moneyBar_moneyByPx
        love.graphics.setColor 255, 255, 255
        love.graphics.rectangle "fill", moneyBarX, moneyBarY,
            moneyBarLength, moneyBarHeight
        love.graphics.setColor 255,255,0
        love.graphics.rectangle "fill", moneyBarX + 1, moneyBarY + 1,
            barLength, moneyBarHeight - 2
        love.graphics.setColor 0, 0, 0
        love.graphics.rectangle "fill", moneyBarX + 1 + barLength,
            moneyBarY + 1, moneyBarLength - 2 - barLength, moneyBarHeight - 2

        -- health
        for i = 1, playerLives do
            pic, alpha = nil, nil
            if i <= player.life then
                pic = picHeartFull
                alpha = 255
            else
                pic = picHeartEmpty
                alpha = 100
            love.graphics.setColor 255,255,255, alpha
            love.graphics.draw pic, moneyBarLength + i * 30, moneyBarY

        if @displayMinimap
            @drawMinimap!

        -- FPS
        if true
            love.graphics.setColor 255,255,255
            love.graphics.print "FPS : #{love.timer.getFPS!}", wScr - 100, 10

        -- help
        local helpText
        displayText = if @displayHelp then @helpText else @helpHiddenText
        love.graphics.print displayText, moneyBarX, moneyBarY + 50

    drawMinimap: =>
        love.graphics.translate minimapX, minimapY
        love.graphics.setColor 20,10,10
        love.graphics.rectangle "fill", 0, 0, minimapLength, minimapHeight
        love.graphics.setColor 10, 20, 10
        love.graphics.rectangle "fill",
            (mapMinX - subMapMinX) / minimapXfactor,
            (mapMinY - subMapMinY) / minimapYfactor,
            (mapMaxX - mapMinX) / minimapXfactor,
            (mapMaxY - mapMinY) / minimapYfactor

        -- outlines
        love.graphics.setColor 0, 0, 0
        love.graphics.rectangle "line", 0, 0, minimapLength, minimapHeight
        love.graphics.setColor 100, 100, 100
        love.graphics.rectangle "line",
            (mapMinX - subMapMinX) / minimapXfactor,
            (mapMinY - subMapMinY) / minimapYfactor,
            (mapMaxX - mapMinX) / minimapXfactor,
            (mapMaxY - mapMinY) / minimapYfactor

        -- all the dudes
        for d in dudeList\iter!
            miniSize, miniColors = nil, nil
            switch d\class!
                when "poor"
                    miniColors = poorColor
                    miniSize = 3
                when "middle"
                    miniColors = middleColor
                    miniSize = 1
                when "rich"
                    miniColors = richColor
                    miniSize = 3
                when "rich+"
                    miniColors = richPlusColor
                    miniSize = 5

            love.graphics.setColor miniColors
            love.graphics.rectangle "fill",
                minimapLength / 2 + d.x / minimapXfactor,
                minimapHeight / 2 + d.y / minimapYfactor,
                miniSize, miniSize

        -- player
        love.graphics.setColor 0, 255, 255
        love.graphics.rectangle "fill",
            minimapLength /2 + player.x / minimapXfactor,
            minimapHeight /2 + player.y / minimapYfactor,
            4, 4
        love.graphics.translate -minimapX, -minimapY
