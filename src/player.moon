export ^

class Player extends Dude
    new: =>
        -- FIXME (?) Player inherits Dude buts does not call constructor
        @items = {}
        @id = 0
        @x = (mapMinX + mapMaxX) / 2
        @y = (mapMinY + mapMaxY) / 2
        @money = 950
        @corrupted = false
        @corruptLeakTimer = 0
        @speedX = 0
        @speedY = 0
        @invulnTimer =  0
        @life = playerLives

        @weaponRadius = 0
        @maxWeaponRadius = playerWeaponRadiusMax -- can be increased with items

    draw: =>
        love.graphics.setColor 0, 1, 1
        fillage = if @invulnTimer <= 0 then "fill" else "line"
        sizeCorruptionFactor = if @corrupted then 2 else 1

        love.graphics.rectangle fillage,
            @x - sizeCorruptionFactor * playerSize / 2,
            @y - sizeCorruptionFactor * playerSize / 2,
            sizeCorruptionFactor * playerSize,
            sizeCorruptionFactor * playerSize

        if @weaponRadius > 0
            love.graphics.circle "line",
                @x, @y, @weaponRadius, @weaponRadius

    update: (dt) =>
        @x += @speedX * dt
        @y += @speedY * dt

        -- speed update
        speedFactor = if not @corrupted then 1 else playerCorruptionSpeedFactor

        -- key Presses
        if love.keyboard.isDown("z") or love.keyboard.isDown("w")
            @speedY -= speedFactor * playerSpeedKeyDownIncrease * dt
        elseif @speedY < 0
            @speedY = math.min(0, @speedY + playerSpeedKeyUpDecrease * dt)

        if love.keyboard.isDown("s")
            @speedY += speedFactor * playerSpeedKeyDownIncrease * dt
        elseif @speedY > 0
            @speedY = math.max(0, @speedY - playerSpeedKeyUpDecrease * dt)

        if love.keyboard.isDown("a") or love.keyboard.isDown("q")
            @speedX -= speedFactor * playerSpeedKeyDownIncrease * dt
        elseif @speedX < 0
            @speedX = math.min(0, @speedX + playerSpeedKeyUpDecrease * dt)

        if love.keyboard.isDown("d")
            @speedX += speedFactor * playerSpeedKeyDownIncrease * dt
        elseif @speedX > 0
            @speedX = math.max(0, @speedX - playerSpeedKeyUpDecrease * dt)

        -- attack
        if love.keyboard.isDown("space") and @invulnTimer <= 0
            if not @corrupted
                weaponRadius = @weaponRadius + playerWeaponRadiusSpeed * dt
                @weaponRadius = math.min(weaponRadius, @maxWeaponRadius)
        elseif @weaponRadius > 0
            @attack(@weaponRadius)
            @weaponRadius = 0

        -- corruption
        if @corrupted
            if @money < 0.75 * playerMaxMoney
                @corrupted = false
            if @corruptLeakTimer <= 0
                @corruptLeakTimer = playerCorruptionLeakTimer
                @updateMoney -playerCorruptionLeakValue
                dirX = math.random(-100,100) / 100
                dirY = math.random(-100,100) / 100
                coinList\createCoinBatchWithDirection @x, @y,
                    playerCorruptionLeakValue, dirX, dirY

        -- timer
        @invulnTimer -= dt if @invulnTimer > 0
        @corruptLeakTimer -= dt if @corruptLeakTimer > 0

    attack: (weaponRadius) =>
        for prey in dudeList\iter()
            if prey.invulnTimer <= 0 and distance2Entities(@, prey) < weaponRadius
                moneyStolen = prey.money/2
                prey\isAttacked(@, moneyStolen)

    isAttacked: =>
        @money = math.max(0, @money - moneyStolenByHit)
        coinList\createCoinBatch(@x, @y, moneyStolenByHit)
        @invulnTimer = playerInvulnTimeByHit
        @life -= 1

    dudeSize: =>
        playerSize

    class: =>
        "player"

    updateMoney: (amount) =>
        -- negative/positive amount : take/give money

        super(amount)

        if @money > playerMaxMoney
            @life -= 1
            @corrupted = true
            @moneyDrop(@money - playerMaxMoney)

    moneyDrop: (amount) =>
        droppedAmount = math.min(@money, amount)
        coinList\createCoinBatch(@x, @y, droppedAmount)
        @updateMoney -droppedAmount

    getItem: (item) =>
        table.insert(@items, item)
        if item.name == "YOU LOOSE"
            @life = 0
        elseif item.name == "YOU WIN"
            print("Life's not that easy!")
            @life = 0
        elseif item.name == "Useless"
            assert true == true, "42"
        elseif item.name == "Health Potion"
            if @life < playerLives
                @life += 1
        elseif item.name == "Eagle eye"
            @maxWeaponRadius *= 1.1


    keypressed: (k) =>
        switch k
            when "lshift"
                @moneyDrop(playerMegaDropAmount)
            when "e"
                @moneyDrop(playerMiniDropAmount)
