export ^

class FireBallList extends EntityList
    createFireBall: (sender, destX, destY) =>
        @add(FireBall(sender, destX, destY))

    update: (dt) =>
        for fb in @iter()
            fb\update(dt)
            if fb.lifeTime <= 0
                @removeID(fb.id)

class FireBall extends Entity
    new: (@sender, destX, destY) =>
        super(@sender\getX(), @sender\getY())
        @speedX, @speedY = bafaltomVector(@x, @y, destX, destY, fireballSpeed)
        @lifeTime = fireballLifeTime

    update: (dt) =>
        @x += @speedX * dt
        @y += @speedY * dt

        -- Hit detection
            -- player
        if distance2Entities(player, @) < player\dudeSize() and player.invulnTimer <= 0 and not (@lifeTime < fireballFadeTimer)
            player\isAttacked()
            @lifeTime = 0

        -- Timer decrease
        @lifeTime -= dt

    draw: =>
        fadeFactor = math.max(0, math.min(1, @lifeTime/fireballFadeTimer))
        -- create "firework" look when fading. Unintended but pretty cool!
        love.graphics.setColor(1, 100 / 255, 0, fadeFactor)
        love.graphics.circle("fill", @getX(), @getY(), 5, 20)

    getX: =>
        @x
    getY: =>
        @y
