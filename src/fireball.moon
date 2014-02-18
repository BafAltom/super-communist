export ^

class FireBallList extends EntityList
    createFireBall: (x, y, destX, destY) =>
        @add Fireball x, y, destX, destY

    update: (dt) =>
        for fb in #@entList
            fb\update dt
            if fb.lifeTime <= 0
                @remove fb.id

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
