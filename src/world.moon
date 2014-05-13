export ^

class World
    new: =>
        @offsetX = 0
        @offsetY = 0
        @scaleFactor = 1

    update: (dt) =>
        player\update(dt)
        ui\update(dt)
        shop\update(dt)
        for dude in dudeList\iter()
            dude\update(dt)

        for coin in coinList\iter()
            coin\update(dt)

        for fb in fireballList\iter()
            fb\update(dt)


    draw: =>
        @translateAxes()

        @drawMapGrid()

        for dude in dudeList\iter()
            dude\draw()

        for coin in coinList\iter()
            coin\draw()

        for fb in fireballList\iter()
            fb\draw()

        player\draw()

        @inverseTranslateAxes()

    keypressed: (k) =>
        if k == "tab" and not shop.opened
            shop\open()
        elseif shop.opened
            shop\keypressed(k)
        player\keypressed(k)

    drawMapGrid: =>
        -- suburbs
        love.graphics.setColor(20, 10, 10)
        love.graphics.rectangle("fill", subMapMinX, subMapMinY, subMapMaxX - subMapMinX, subMapMaxY - subMapMinY)

        -- maps
        love.graphics.setColor(10, 20, 10)
        love.graphics.rectangle("fill", mapMinX, mapMinY, mapMaxX - mapMinX, mapMaxY - mapMinY)

        -- columns
        love.graphics.setColor(100, 100, 100)
        for i = 0, gridColumns
            love.graphics.line mapMinX + (i * (mapMaxX - mapMinX) / gridColumns),
                mapMinY,
                mapMinX + (i * (mapMaxX - mapMinX) / gridColumns),
                mapMaxY
        -- rows
        for i = 0, gridRows
            love.graphics.line mapMinX,
                mapMinY + (i * (mapMaxY-mapMinY) / gridRows),
                mapMaxX,
                mapMinY + (i * (mapMaxY-mapMinY) / gridRows)

    translateAxes: =>
        @offsetX = -1 * player.x + wScr / 2
        @offsetY = -1 * player.y + hScr / 2

        @scaleFactor = 1
        love.graphics.scale(@scaleFactor, @scaleFactor)
        love.graphics.translate(@offsetX * @scaleFactor, @offsetY * @scaleFactor)

    inverseTranslateAxes: =>
        love.graphics.translate(-@offsetX * @scaleFactor, -@offsetY * @scaleFactor)
        love.graphics.scale(1 / @scaleFactor, 1 / @scaleFactor)

    isEntityInScreen: (entity, tolerance) =>
    --tolerance : allow the entity to be outside (> 0) or inside (< 0) the screen by that amount of pixels
    -- remark : this suppose that the screen is centered on the player
        outByX = math.abs(entity.x - player.x) > wScr / 2 + tolerance
        outByY = math.abs(entity.y - player.y) > hScr / 2 + tolerance
        return not (outByX or outByY)
