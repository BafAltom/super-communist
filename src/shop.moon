export ^

class Shop
    new: =>
        @items = {}
        @currentCol = 0
        @currentRow = 0

        @fadeTimer = 0
        @fadeIn = false
        @fadeOut = false

        @opened = false
        @active = false

        table.insert shop.items, Item("YOU WIN", picItemPlaceHolder, "That is totally OP!", 10)
        table.insert shop.items, Item("YOU LOOSE", picItemPlaceHolder, "Why would I buy this?", 10)
        table.insert shop.items, Item("Useless", picItemPlaceHolder, "I have too much money", 10)
        table.insert shop.items, Item("YOU LOOSE", picItemPlaceHolder, "Why would I buy this?", 10)
        table.insert shop.items, Item("YOU WIN", picItemPlaceHolder, "That is totally OP!", 10)
        table.insert shop.items, Item("YOU LOOSE", picItemPlaceHolder, "Why would I buy this?", 10)

    rowCount: =>
        math.floor #@items / shopItemPerRow

    itemCntInRow: (rowNumber) =>
        assert 0 <= rowNumber, "itemNbrInShopRow: rowNumber must be > 0"
        assert rowNumber <= shop\rowCount!, "itemNbrInShopRow: rowNumber must be < shopRowCount (#{shop\rowCount!})"
        if  rowNumber < shop\rowCount!
            return shopItemPerRow
        else
            return #@items % shopItemPerRow

    itemNbr: (row, col) =>
        row * shopItemPerRow + col + 1

    draw: =>
        if @opened then
            fadeFactor = math.max(0, math.min(1, @fadeTimer)) / shopFadeTime
            love.graphics.translate -shopRectangle[3] * (1 - fadeFactor), 0
            love.graphics.setColor 0,0,0, 100
            love.graphics.rectangle "fill",
                shopRectangle[1], shopRectangle[2],
                shopRectangle[3], shopRectangle[4]
            for i, item in ipairs @items
                column = (i - 1) % shopItemPerRow
                row = math.floor((i - 1) / shopItemPerRow)
                x = shopRectangle[1] + shopItemMargin + (shopItemSize[1] + shopItemMargin) * column
                y = shopRectangle[2] + shopItemMargin + (shopItemMargin + shopItemSize[2]) * row

                love.graphics.setColor 0,0,0,255
                if column == @currentCol and row == @currentRow
                    if item.price > player.money
                        love.graphics.setColor 255,0,0,255
                    else
                        love.graphics.setColor 255,255,255,255
                love.graphics.rectangle "line",
                    x, y, shopItemSize[1], shopItemSize[2]
                love.graphics.setColor 255,255,255,200
                love.graphics.print item.name, x, y
                love.graphics.draw item.pic, x, y + 15
                love.graphics.print item.descr, x, y + shopItemSize[2] - 20
                love.graphics.setColor 255, 255, 0
                love.graphics.print item.price, x + shopItemSize[1] - 15, y
                love.graphics.setColor 255, 255, 255, 255
            love.graphics.translate shopRectangle[3] * fadeFactor, 0

    update: (dt) =>
        if @fadeOut
            if @fadeTimer > 0
                @fadeTimer -= dt
            else
                @opened = false
                @fadeOut = false
        elseif @fadeIn
            if @fadeTimer < shopFadeTime
                @fadeTimer += dt
            else
                @active = true
                @fadeIn = false

    open: =>
        @opened = true
        @active = false
        @fadeIn = true
        @fadeOut = false

    close: =>
        @active = false
        @fadeOut = true
        @fadeIn = false

    keypressed: (k) =>
        switch k
            when "tab"
                @close!
            when "left"
                @currentCol = math.max(0, @currentCol - 1)
            when "right"
                @currentCol = math.min(@itemCntInRow(@currentRow) - 1, @currentCol + 1)
            when "up"
                @currentRow = math.max(0, @currentRow - 1)
            when "down"
                @currentRow = math.min(@rowCount!, @currentRow + 1)
                @currentCol = math.min(@currentCol, @itemCntInRow(@currentRow) - 1)
            when "return"
                chosenItemNbr = @itemNbr(@currentRow, @currentCol)
                print "chosenItemNbr : #{chosenItemNbr}"
                chosenItem = @items[chosenItemNbr]
                print "chosenItem name : #{chosenItem.name}"
                if player.money > chosenItem.price
                    player\updateMoney -chosenItem.price
                    player\getItem chosenItem
                    table.remove @items, chosenItemNbr
                else
                    print "You cannot buy this, not enough money"
                    -- TODO: error sound or flash or something
