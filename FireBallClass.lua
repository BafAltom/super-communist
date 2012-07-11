FireBallClass = {}

FireBallClass.nextID = 0
FireBallClass.getNextID = function()
	FireBallClass.nextID = FireBallClass.nextID + 1
	return FireBallClass.nextID
end

FireBallClass.createFireBall = function(x,y,destX,destY)
	table.insert(fireballs,  FireBallClass.new(x,y,destX,destY))
end

FireBallClass.update = function(fb,dt)

	if (fb.lifeTime <= 0) then
		fireballs.removeID(fb.id)
	end

	-- Movement
	fb.x = fb.x + fb.speedX*dt
	fb.y = fb.y + fb.speedY*dt

	-- Hit detection

		-- player
	if (distance2Entities(player,fb) < player:dudeSize() and player.invulnTimer <= 0) then
		player.isAttacked()
		fb.lifeTime = 0
	end


	-- Timer decrease
	fb.lifeTime = fb.lifeTime - dt

end

FireBallClass.draw = function(fb)

	love.graphics.setColor(255,100,0)
	love.graphics.circle("fill", fb.x, fb.y, 5, 20)

end

FireBallClass.new = function(sender, destX, destY)
	fb = {}
	setmetatable(fb, {__index = FireBallClass})
	fb.id = FireBallClass.getNextID
	fb.sender = sender
	fb.x = sender.x
	fb.y = sender.y

	fb.speedX, fb.speedY = myVector(sender.x, sender.y, destX, destY, fireballSpeed)

	fb.lifeTime = fireballLifeTime

	return fb

end

fireballs = {}
fireballs.findID = function(id)
	for _, fb in ipairs(fireballs) do
		if (fb.id == id) then
			return fb
		end
	end
	return nil
end

fireballs.removeID = function(id)
	for n, fb in ipairs(fireballs) do
		if(fb.id == id) then
			table.remove(fireballs, n)
			return
		end
	end
end
