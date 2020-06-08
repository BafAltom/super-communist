export ^

class DudeList extends EntityList
    new: =>
        super()
        poorCount, middleCount , richCount = 0, 0, 0
        for i = 1, numberOfDudes
            dudeX, dudeY, dudeM = nil, nil, nil
            randomPercent = math.random(100)
            if randomPercent < poorPercent -- poor
                poorCount += 1
                dudeX, dudeY = randomPointInSubMapCorners()
                dudeM = math.random(0, moneyMaxPoor)
            else
                dudeX = math.random(mapMinX, mapMaxX)
                dudeY = math.random(mapMinY, mapMaxY)

                if randomPercent < poorPercent + middlePercent -- middle
                    middleCount += 1
                    dudeM = math.random(moneyMaxPoor + 1, moneyMaxMiddle)
                else -- rich
                    richCount += 1
                    moneyMin = moneyMaxRich - (moneyMaxRich-moneyMaxMiddle)*0.5
                    moneyMax = moneyMaxRich - (moneyMaxRich-moneyMaxMiddle)*0.25
                    dudeM = math.random(moneyMin, moneyMax)
            @add(Dude dudeX, dudeY, dudeM)

    find: (id) =>
        if id == 0
            return player
        super id

    areAllMiddle: =>
        for d in *@entList
            if d\class() ~= "middle"
                return false
        return true

    getClassCount: =>
        poorCount, middleCount, richCount, richPlusCount = 0, 0, 0, 0
        for d in *@entList
            if d\class() == "poor"
                poorCount += 1
            elseif d\class() == "middle"
                middleCount += 1
            elseif d\class() == "rich"
                richCount += 1
            elseif d\class() == "rich+"
                richPlusCount += 1
            else
                error("Unknown class #{d\class()}" )
        return {poorCount, middleCount, richCount, richPlusCount}

    getAllRichPlus: =>
        correspondingDudes = {}
        for d in *@entList
            if d\class! == "rich+"
                table.insert correspondingDudes, d
        return correspondingDudes

    getGiniCoefficient: =>
        -- http://en.wikipedia.org/wiki/Gini_coefficient
        dudeList = @as_list()
        n = #dudeList
        totalMoney = 0
        for i, d in ipairs(dudeList)
            totalMoney += d.money
        table.sort(dudeList, (p1, p2) -> p1.money < p2.money)
        -- from Wikipedia:
        -- Xk is the cumulated proportion of the population variable, for k = 0,...,n
        -- Yk is the cumulated proportion of the income variable, for k = 0,...,n
        -- G_1 = 1 - \sum_{k=1}^{n} (X_{k} - X_{k-1}) (Y_{k} + Y_{k-1})
        -- (note: this seems weird to me)
        oldX = 0
        oldY = 0
        cumulMoney = 0
        cumulArea = 0
        for i, d in ipairs(dudeList)
            newMoney = d.money / totalMoney
            cumulMoney += newMoney
            newX = i / n
            newY = cumulMoney
            cumulArea += (newX - oldX) * (newY + oldY)
            oldX = newX
            oldY = newY
        return 1 - cumulArea

class Dude extends Entity
    new: (x, y, @money) =>
        super(x, y)
        if @class() ~= "poor" then
            @x = math.random(mapMinX, mapMaxX)
            @y = math.random(mapMinY, mapMaxY)
        else
            -- poor dudes generation in submap
            -- first choose a "quadrant" (up, down, left or right)
            -- then a position in this quadrant
            quadrant = math.random(1, 4)
            coord1 = math.random(-subMapSize, subMapSize)
            coord2 = math.random(mapSize, subMapSize)
            if quadrant == 1
                -- UP quadrant
                @x = coord1
                @y = -coord2
            elseif quadrant == 2
                -- RIGHT quadrant
                @x = coord2
                @y = coord1
            elseif quadrant == 3
                -- DOWN quadrant
                @x = coord1
                @y = coord2
            elseif quadrant == 4
                -- LEFT
                @x = -coord2
                @y = coord1
        @destX = @x
        @destY = @y
        @speedX = 0
        @speedY = 0
        @waitingTime = 0
        @richPlusCooldown = 0
        @invulnTimer = 0
        @currentPrey = nil -- current target (dude)
        @attacked = -1 -- id of attacked dude (-1 if void)
        @attackedBy = -1 -- id of attacking dude (-1 if void)
        @attackTimer = 0
        @moneyDisplayTimer = 0
        @state = ''
        @findNewDestination()
        @setState 'walking'

    draw: =>
        dudeColors = nil
        switch @class()
            when "poor"
                dudeColors = poorColor
            when "middle"
                dudeColors = middleColor
            when "rich"
                dudeColors = richColor
            when "rich+"
                dudeColors = richPlusColor
            else
                error "dude class '#{dude\class!}' is not recognized"
        love.graphics.setColor dudeColors

        dudeSize = @dudeSize()
        --- PROGRAMMER GRAPHICS
        fillage = if @invulnTimer <= 0 then "fill" else "line"
        love.graphics.rectangle fillage, @x - dudeSize / 2, @y - dudeSize / 2, dudeSize, dudeSize

        if DEBUG
            love.graphics.print(@id, @getX() + dudeSize + 5, @getY())
            love.graphics.print(@state, @getX() + dudeSize + 5, @getY() + 10)
            love.graphics.print "w: #{@waitingTime}",
                @getX() + dudeSize + 5, @getY() + 30
            if @class() == 'rich'
                love.graphics.print(@attackTimer, @getX() + dudeSize + 5, @getY() + 20)
                -- draw prey circle
                love.graphics.circle("line", @getX(), @getY(), @preyRadius(), 50)

        -- draw moneyBar
        if @moneyDisplayTimer > 0
            dudeM = math.ceil(@money)
            moneyMin, moneyMax = nil, nil
            if dudeM <= moneyMaxPoor
                moneyMin, moneyMax = 0, moneyMaxPoor
            elseif dudeM <= moneyMaxMiddle
                moneyMin, moneyMax = moneyMaxPoor, moneyMaxMiddle
            elseif dudeM <= moneyMaxRich
                moneyMin, moneyMax = moneyMaxMiddle, moneyMaxRich
            if moneyMax ~= nil
                relativeMoney = (dudeM - moneyMin) / (moneyMax - moneyMin)
                colorAlpha = 255
                if @moneyDisplayTimer < dudeMoneyFade
                    colorAlpha =  @moneyDisplayTimer / dudeMoneyFade
                -- love.graphics.print("#{moneyMin} < #{dudeM} < #{moneyMax}", @x, @y)
                love.graphics.setColor(0, 0, 0, colorAlpha)
                love.graphics.rectangle "line",
                    @getX() - 20, @getY() - 40, 40, 10 -- magic numbers!
                love.graphics.setColor(1, 1, 0, colorAlpha)
                love.graphics.rectangle "fill",
                    @getX() - 19, @getY() - 39,
                    math.floor(relativeMoney * 38), 8 -- magic numbers!

        -- draw lightning
        if @currentPrey ~= nil and @class() ~= "rich+"
            attackedDude = @currentPrey
            attackBuildUpFactor = 1 - (@attackTimer / richHitTimer)
            distance = distance2Entities(@, attackedDude)
            endX, endY = bafaltomVector @getX(), @getY(),
                attackedDude\getX(), attackedDude\getY(),
                distance * attackBuildUpFactor

            love.graphics.setColor(1, 69 / 255, 0, attackBuildUpFactor)
            love.graphics.line(@getX(), @getY(), @getX() + endX, @getY() + endY)

        -- draw dest Path
        if DEBUG
            love.graphics.setColor(dudeColors)
            love.graphics.line(@getX(), @getY(), @destX, @destY)

    class: =>
        if @money <= moneyMaxPoor
            return "poor"
        elseif @money <= moneyMaxMiddle
            return "middle"
        elseif @money < moneyMaxRich
            return "rich"
        else
            return "rich+"

    update: (dt) =>
        @x += @speedX * dt
        @y += @speedY * dt

        -- dude pathfinding
        if @class() == "rich+"
            if @richPlusCooldown > 0
                @richPlusCooldown -= dt
                @destX = @x
                @destY = @y
            else if distance2Entities(@, player) > richPlusStalkDistance
                @destX = player.x
                @destY = player.y
                @setState 'playerPursuing'
            else
                @destX = @x
                @destY = @y
        else
            -- arrived at destination?
            distDest = distance2Points(@getX(), @getY(), @destX, @destY)
            if distDest <= destAcceptanceRadius
                if @state ~= 'waiting'
                    @destX = @getX()
                    @destY = @getY()
                    @setState 'waiting'
                    @waitingTime = math.random(dudeNextDestWaitTimeMin,dudeNextDestWaitTimeMax)
                elseif @waitingTime > 0
                    @waitingTime -= dt
                else
                    @findNewDestination()
                    @setState 'walking'
            -- attracted by coins
            closestCoin = @findClosestCoin()
            if closestCoin ~= nil and @state ~= 'fleeing'
                @destX = closestCoin.x
                @destY = closestCoin.y
                @setState 'moneyPursuing'
            if closestCoin == nil and @state == 'moneyPursuing'
                -- this dude was attracted to a coin which doesn't exist anymore
                @destX = @x
                @destY = @y
                @setState 'walking'

        -- calculate new speed
        newSpeedX, newSpeedY = 0, 0
        if @x ~= @destX or @y ~= @destY
            newSpeedX, newSpeedY = bafaltomVector(@x, @y, @destX, @destY, dudeMaxSpeed)

        -- Be pushed by bigger dudes around
        if @class() ~= "rich+"
            closestDude, closestDudeDistance = findClosestOf dudeList\as_list(), @
            if closestDude ~= nil and closestDude\dudeSize() > @dudeSize() and closestDudeDistance < closestDude\dudeSize()
                -- hotfix
                if @getX() == closestDude\getX() and @getY() == closestDude\getY()
                     closestDude.x = closestDude.x + 1
                bumpSpeedX, bumpSpeedY = bafaltomVector closestDude.x, closestDude.y, @x, @y, dudeMaxSpeed
                newSpeedX += bumpSpeedX
                newSpeedY += bumpSpeedY

        @normalizeSpeed(newSpeedX, newSpeedY)

        if isNan(@speedX) or isNan(@speedY)
            error("isNan")

        -- prey on the weak
        if @class() == "rich"
            if @invulnTimer <= 0 and (@state == "walking" or @state == "waiting")
                prey = @findClosestPrey()
                if prey ~= nil
                    if @attackTimer < 0
                        @attackTimer = richHitTimer
                        @attacked = prey.id
                        @attackTimer = richHitTimer
                        stolenMoney = math.min(prey.money, moneyStolenByHit)
                        prey\isAttacked(@, stolenMoney)
                    else
                        @attackTimer -= dt
                else
                    @attackTimer = richHitTimer
                @currentPrey = prey
            else
                @attackTimer = richHitTimer

        -- rich+ shoot Fireballz
        if @class() == "rich+" and not (@attackTimer > 0) and not (@richPlusCooldown > 0) and distance2Entities(@, player) < superRichHitDistance
            fireballList\createFireBall(@, player.x, player.y)
            @attackTimer = fireBallAttackTimer
            @attacked = 0

        -- flee
        if @attackedBy ~= -1
            attacker = dudeList\find(@attackedBy)
            destX = @getX() + 2 * (@getX() - attacker\getX())
            destY = @getY() + 2 * (@getY() - attacker\getY())
            destX = math.max(destX, fleeMinX)
            destX = math.min(destX, fleeMaxX)
            destY = math.max(destY, fleeMinY)
            destY = math.min(destY, fleeMaxY)
            @destX, @destY = destX, destY
            @attackedBy = -1
            @setState 'fleeing'

        -- timers
        @invulnTimer -= dt if @invulnTimer > 0
        @moneyDisplayTimer -= dt if @moneyDisplayTimer > 0
        @attackTimer -= dt if @class() == "rich+" and @attackTimer > 0


    updateMoney: (amount) => -- negative/positive amount : take/give money
        previousClass = @class()
        @money += amount
        if @class() ~= previousClass
            @changeClass(previousClass)
        @moneyDisplayTimer = dudeMoneyTimer

    changeClass: (previousClass) =>
        if previousClass == "rich"
            @currentPrey = nil
        if @class() == "rich+"
            @richPlusCooldown = superRichCooldown
        @attackTimer = 0
        @waitingTime = invulnTimeByClassChange
        @setState "waiting"

    preyRadius: =>
        if @class() ~= "rich"
            return 0
        else
            return @money * moneyRadiusFactor

    findClosestPrey: =>
        filteredDudes = {}
        for d in dudeList\iter()
            if (d.money < @money) and not (d.invulnTimer > 0)
                table.insert filteredDudes, d
        findClosestOf filteredDudes, @, @preyRadius()

    findClosestCoin: =>
        findClosestOf coinList\as_list(), @, dudeAttractionDistance

    getX: =>
        @x

    getY: =>
        @y

    dudeSize: =>
        math.max(5, @money / 10)

    isAttacked: (predator, moneyStolen) =>
        @updateMoney(-1 * moneyStolen)
        coinList\createCoinBatchWithDirection(@getX(), @getY(), moneyStolen, 0, 0)
        @attackedBy = predator.id
        @invulnTimer = invulnTimeByHit

    findNewDestination: =>
        if @class() == "poor" and not isInSubMap(@getX(), @getY())
            -- poor go to the closest suburbs corner
            @destX = if @getX() - subMapMinX < subMapMaxX - @getX() then subMapMinX else subMapMaxX
            @destY = if @getY() - subMapMinY < subMapMaxY - @getY() then subMapMinY else subMapMaxY
        else
            @destX = math.random(@x - dudeNextDestRadius, @x + dudeNextDestRadius)
            @destY = math.random(@y - dudeNextDestRadius, @y + dudeNextDestRadius)

            local limitMinX, limitMaxX, limitMinY, limitMaxY
            if @class() == "poor"
                limitMinX = subMapMinX
                limitMaxX = subMapMaxX
                limitMinY = subMapMinY
                limitMaxY = subMapMaxY
            else
                limitMinX = mapMinX
                limitMaxX = mapMaxX
                limitMinY = mapMinY
                limitMaxY = mapMaxY
            @destX = math.max(limitMinX, @destX)
            @destX = math.min(limitMaxX, @destX)
            @destY = math.max(limitMinY, @destY)
            @destY = math.min(limitMaxY, @destY)
            @setState 'walking'

    normalizeSpeed: (newSpeedX, newSpeedY) =>
        if newSpeedX == 0 and newSpeedY == 0
            @speedX, @speedY = newSpeedX, newSpeedY
        else
            @speedX, @speedY = bafaltomVector(0, 0, newSpeedX, newSpeedY, dudeMaxSpeed)

    acceptedStates: {
        'waiting'
        'walking'
        'fleeing'
        'moneyPursuing'
        'playerPursuing'
    }

    setState: (newState) =>
        for _,s in ipairs Dude.acceptedStates
            if newState == s
                @state = newState
                return
        error('Dude.setState(newState) : newState = '..newState..' was not in accepted states')

