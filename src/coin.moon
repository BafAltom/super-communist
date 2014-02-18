export ^

class CoinList
    new: =>
        @coinList = {}

    add: (c) =>
        table.insert @coinList, c

    getID: (id) =>
        for _, c in ipairs @coinList
            if c.id == id
                return c
        return nil

    removeID: (id) =>
        for n, c in ipairs @coinList
            if c.id == id
                table.remove @coinList, n
                -- return

class Coin
    nextID = 0
    getNextID = ->
        Coin.nextID += 1

    createCoinBatch: (x, y, totalValue) =>
        createCoinBatchWithDirection x, y, totalValue, 0, 0

    createCoinBatchWithDirection: (x, y, totalValue, vx, vy) =>
        value = totalValue
        while value > 0
            choice = math.random(1,coinsChoiceNumber)
            while coinsAcceptedValue[choice] > value and choice > 1
                choice -= 1
            table.insert coins, Coin x, y, coinsAcceptedValue[choice], vx, vy
            value -= coinsAcceptedValue[choice]

    new: (@x, @y, @value, sx, sy) =>
        @id = Coin.getNextID!
        if sx ~= 0 and sy ~= 0 then
            -- need refactoring :(
            if (sx > 0) then
                @speedX = math.random 0, sx * 10
            else
                @speedX = math.random sx * 10, 0
            if (sy > 0) then
                @speedY = math.random 0, sy * 10
            else
                @speedY = math.random sy * 10, 0
        else -- Random direction
            @speedX = math.random(-100, 100) / 100
            @speedY = math.random(-100, 100) / 100
        @normalizeSpeed(math.random coinsMaxSpeed * 0.5, coinsMaxSpeed)
        @accX = 0
        @accY = 0
        @noCatchTimer = coinsNoCatchTime
        @lifeTime = coinsLifeTime

    normalizeSpeed: (speed) =>
        @speedX, @speedY = bafaltomVector 0, 0, @speedX, @speedY, speed

    update: (dt) =>
        @lifeTime -= dt

        if @lifeTime < 0
            Coins.removeID(coin.id)

        if @noCatchTimer <= 0
            -- Find closest Dude (or player)
            closestDude = @findClosestDude!

            -- Move towards him
            if @closestDude ~= nil and not closestDude.invulnTimer > 0 and not closestDude\class! == "rich+"

                -- magic numbers
                @accX = (closestDude.x - @x) * 20
                @accY = (closestDude.y - @y) * 20
            else
                @accX = -@speedX
                @accY = -@speedY

            -- Caught by him?
            if closestDude ~= nil and @noCatchTimer <= 0 and closestDude.invulnTimer <= 0 and closestDude\class! ~= "rich+"
                    if (distance2Entities coin, closestDude) < closestDude\dudeSize!
                        closestDude\updateMoney coin.value
                        Coins.removeID coin.id
        else
            @noCatchTimer -= dt

        -- Speed Update
        @speedX += @accX * dt
        @speedY += @accY * dt
        actualSpeed = math.sqrt @speedX * @speedX + @speedY * @speedY
        if actualSpeed > coinsMaxSpeed
            @speedX, @speedY = bafaltomVector 0, 0, @speedX, @speedY, coinsMaxSpeed

        -- Pos Update
        @x += @speedX * dt
        @y += @speedY * dt

    findClosestDude: =>
        filteredDudes = {} -- dudes which can attract coins
        for _,d in ipairs(dudes)
            if d\class! ~= "rich+" and d.invulnTimer <= 0
                table.insert filteredDudes, d
        if not player.corrupted
            table.insert filteredDudes, player
        return findClosestOf filteredDudes, coin, coinsAttractionDistance

    draw: => -- TODO clean up a bit?
        love.graphics.setColor 255,255,0
        coinRadius = math.max 1, @value / coinsValuePerPx
        if @lifeTime < coinsFadeTime
            fadeFactor = @lifeTime / coinsFadeTime
            coinRadius = math.max 1, coinRadius * fadeFactor
            love.graphics.setColor 255 * fadeFactor, 255 * fadeFactor, 0
        fillage = "fill"
        if @noCatchTimer > 0
            fillage = "line"
        love.graphics.circle fillage, @getX!, @getY!, coinRadius, coinRadius * 4

        if DEBUG
            love.graphics.print @id, @getX! + 5, @getY!
            closestDude = @findClosestDude!
            if closestDude ~= nil
                love.graphics.line @getX!, @getY!, closestDude.getX!, closestDude.getY!

    getX: =>
        return @x

    getY: =>
        return @y
