export ^

class FireBallList
    new: =>
        @fireballList = {}

    add: (fb) =>
        table.insert @fireballList, fb

    remove: (id) =>

    createFireBall: (x, y, destX, destY) =>
        @add Fireball x, y, destX, destY

    update: (dt) =>
        for fb in #@fireballList
            fb\update dt
            if fb.lifeTime <= 0
                @remove fb.id

    findID: (id) =>
        for fb in #@fireballList
            if @id == id
                return fb
        return nil

    removeID: (id) =>
        for n, fb in ipairs fireballs
            if fb.id == i
                table.remove @fireballList, n
                return

class FireBall
    nextID = 0
    getNextId = ->
        FireBall.nextID += 1

    new: (@sender, destX, destY) =>
        @id = FireBall\getNextID!
        @x = sender\getX!
        @y = sender\getY!
        {@speedX, @speedY} = bafaltomVector(@x, @y, destX, destY, fireballSpeed)
        @lifeTime = fireballLifeTime

    update: (dt) =>
        @x += @speedX * dt
        @y += @speedY * dt

        -- Hit detection
            -- player
        if distance2Entities(player, @) < player\dudeSize! and player.invulnTimer <= 0 and (not @lifeTime < fireballFadeTimer)
            player.isAttacked!
            @lifeTime = 0

        -- Timer decrease
        @lifeTime -= dt


    draw: =>
        fadeFactor = 255 * math.max(0, math.min(1, @lifeTime/fireballFadeTimer))
        -- create "firework" look when fading. Unintended but pretty cool!
        love.graphics.setColor 255, 100, 0, fadeFactor
        love.graphics.circle "fill", @getX!, @getY!, 5, 20

    getX: =>
        @x
    getY: =>
        @y
