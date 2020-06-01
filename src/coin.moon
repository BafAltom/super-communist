export ^

class CoinList extends EntityList
    createCoinBatch: (x, y, totalValue) =>
        @createCoinBatchWithDirection(x, y, totalValue, 0, 0)

    createCoinBatchWithDirection: (x, y, totalValue, vx, vy) =>
        value = totalValue
        while value > 0
            choice = math.random(1,coinsChoiceNumber)
            while coinsAcceptedValue[choice] > value and choice > 1
                choice -= 1
            @add Coin(x, y, coinsAcceptedValue[choice], vx, vy)
            value -= coinsAcceptedValue[choice]

class Coin
    new: (@x, @y, @value, sx, sy) =>
        if sx ~= 0 and sy ~= 0 then
            -- need refactoring :(
            if sx > 0 then
                @speedX = math.random 0, sx * 10
            else
                @speedX = math.random sx * 10, 0
            if sy > 0 then
                @speedY = math.random 0, sy * 10
            else
                @speedY = math.random sy * 10, 0
        else -- Random direction
            @speedX = math.random(-100, 100) / 100
            @speedY = math.random(-100, 100) / 100
        @normalizeSpeed(math.random(coinsMaxSpeed * 0.5, coinsMaxSpeed))
        @accX = 0
        @accY = 0
        @noCatchTimer = coinsNoCatchTime
        @lifeTime = coinsLifeTime

    normalizeSpeed: (speed) =>
        @speedX, @speedY = bafaltomVector(0, 0, @speedX, @speedY, speed)

    update: (dt) =>
        @lifeTime -= dt

        if @noCatchTimer <= 0
            -- Find closest Dude (or player)
            closestDude = @findClosestDude!

            -- Move towards him
            if closestDude ~= nil and not (closestDude.invulnTimer > 0) and not (closestDude\class! == "rich+")

                -- magic numbers
                @accX = (closestDude.x - @x) * 20
                @accY = (closestDude.y - @y) * 20
            else
                @accX = -@speedX
                @accY = -@speedY

            -- Caught by him?
            if closestDude ~= nil and @noCatchTimer <= 0 and closestDude.invulnTimer <= 0 and closestDude\class! ~= "rich+"
                    if distance2Entities(@, closestDude) < closestDude\dudeSize()
                        closestDude\updateMoney(@value)
                        coinList\removeID(@id)
        else
            @noCatchTimer -= dt

        -- Speed Update
        @speedX += @accX * dt
        @speedY += @accY * dt
        actualSpeed = math.sqrt(@speedX * @speedX + @speedY * @speedY)
        if actualSpeed > coinsMaxSpeed
            @speedX, @speedY = bafaltomVector(0, 0, @speedX, @speedY, coinsMaxSpeed)

        -- Pos Update
        @x += @speedX * dt
        @y += @speedY * dt

    findClosestDude: =>
        filteredDudes = {} -- dudes which can attract coins
        for d in dudeList\iter!
            if d\class! ~= "rich+" and d.invulnTimer <= 0
                table.insert(filteredDudes, d)
        if not player.corrupted
            table.insert(filteredDudes, player)
        return findClosestOf(filteredDudes, @, coinsAttractionDistance)

    draw: => -- TODO clean up a bit?
        love.graphics.setColor 1, 1, 0
        coinRadius = math.max(1, @value / coinsValuePerPx)
        if @lifeTime < coinsFadeTime
            fadeFactor = @lifeTime / coinsFadeTime
            coinRadius = math.max(1, coinRadius * fadeFactor)
            love.graphics.setColor(fadeFactor, fadeFactor, 0)
        fillage = "fill"
        if @noCatchTimer > 0
            fillage = "line"
        love.graphics.circle(fillage, @getX(), @getY(), coinRadius, coinRadius * 4)

        if DEBUG
            love.graphics.print(@id, @getX() + 5, @getY())
            closestDude = @findClosestDude!
            if closestDude ~= nil
                love.graphics.line(@getX(), @getY(), closestDude\getX(), closestDude\getY())

    getX: =>
        return @x

    getY: =>
        return @y
