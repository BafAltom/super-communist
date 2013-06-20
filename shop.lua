require("variables")
require("item")

shop = {}

shop.items = {}
shop.currentCol = 0
shop.currentRow = 0

shop.fadeTimer = 0
shop.fadeIn = false
shop.fadeOut = false

shop.opened = false
shop.active = false

table.insert(shop.items, newItem("YOU WIN", picItemPlaceHolder, "That is totally OP!", 10))
table.insert(shop.items, newItem("YOU LOOSE", picItemPlaceHolder, "Why would I buy this?", 10))
table.insert(shop.items, newItem("Useless", picItemPlaceHolder, "I have too much money", 10))
table.insert(shop.items, newItem("YOU LOOSE", picItemPlaceHolder, "Why would I buy this?", 10))
table.insert(shop.items, newItem("YOU WIN", picItemPlaceHolder, "That is totally OP!", 10))
table.insert(shop.items, newItem("YOU LOOSE", picItemPlaceHolder, "Why would I buy this?", 10))

function shop.rowCount(shop)
	return math.floor(#shop.items / shopItemPerRow)
end

function shop.itemCntInRow(shop, rowNumber)
	assert(0 <= rowNumber, "itemNbrInShopRow: rowNumber must be > 0")
	assert(rowNumber <= shop:rowCount(), "itemNbrInShopRow: rowNumber must be < shopRowCount ("..shop:rowCount()..")")
	if (rowNumber < shop:rowCount()) then
		return shopItemPerRow
	else
		return #shop.items % shopItemPerRow
	end
end

function shop.itemNbr(shop, row, col)
	return row*shopItemPerRow + col + 1
end

function shop.draw(shop)
	if shop.opened then
		fadeFactor = math.max(0, math.min(1, shop.fadeTimer))/shopFadeTime
		love.graphics.translate(-shopRectangle[3]*(1-fadeFactor), 0)
		love.graphics.setColor(0,0,0, 100)
		love.graphics.rectangle("fill", shopRectangle[1], shopRectangle[2], shopRectangle[3], shopRectangle[4])
		for i, item in ipairs(shop.items) do
			local _column = (i-1) % shopItemPerRow
			local _row = math.floor((i-1) / shopItemPerRow)
			local _x = shopRectangle[1] + shopItemMargin + (shopItemSize[1] + shopItemMargin)*_column
			local _y = shopRectangle[2] + shopItemMargin + (shopItemMargin + shopItemSize[2])*_row

			love.graphics.setColor(0,0,0,255)
			if (_column == shop.currentCol and _row == shop.currentRow) then
				if (item.price > player.money) then
					love.graphics.setColor(255,0,0,255)
				else
					love.graphics.setColor(255,255,255,255)
				end
			end
			love.graphics.rectangle("line", _x, _y, shopItemSize[1], shopItemSize[2])
			love.graphics.setColor(255,255,255,200)
			love.graphics.print(item.name, _x, _y)                       -- name
			love.graphics.draw(item.pic, _x, _y + 15)                     -- pic
			love.graphics.print(item.descr, _x, _y + shopItemSize[2] - 20) -- descr
			love.graphics.setColor(255,255,0)
			love.graphics.print(item.price, _x + shopItemSize[1] - 15, _y)  -- price
			love.graphics.setColor(255,255,255,255)
		end
		love.graphics.translate(shopRectangle[3]*fadeFactor, 0)
	end
end

function shop.update(shop, dt)
	if shop.fadeOut then
		if shop.fadeTimer > 0 then
			shop.fadeTimer = shop.fadeTimer - dt
		else
			shop.opened = false
			shop.fadeOut = false
		end
	elseif shop.fadeIn then
		if shop.fadeTimer < shopFadeTime then
			shop.fadeTimer = shop.fadeTimer + dt
		else
			shop.active = true
			shop.fadeIn = false
		end
	end
end

function shop.open(shop)
	shop.opened = true
	shop.active = false
	shop.fadeIn = true
	shop.fadeOut = false
end

function shop.close(shop)
	shop.active = false
	shop.fadeOut = true
	shop.fadeIn = false
end

function shop.keypressed(shop, k)
	if (k == "tab") then
		shop:close()
	elseif (k == "left") then
		shop.currentCol = math.max(0,shop.currentCol - 1)
	elseif (k == "right") then
		shop.currentCol = math.min(shop:itemCntInRow(shop.currentRow)-1,shop.currentCol + 1)
	elseif (k == "up") then
		shop.currentRow = math.max(0, shop.currentRow - 1)
	elseif (k == "down") then
		shop.currentRow = math.min(shop:rowCount(), shop.currentRow + 1)
	elseif (k == "return") then
		chosenItemNbr = shop:itemNbr(shop.currentRow, shop.currentCol)
		print("chosenItemNbr :"..chosenItemNbr)
		chosenItem = shop.items[chosenItemNbr]
		print("chosenItem name : "..chosenItem.name)
		if (player.money > chosenItem.price) then
			player:updateMoney(-chosenItem.price)
			player.getItem(chosenItem)
			table.remove(shop.items, chosenItemNbr)
		else
			print("You cannot buy this, not enough money")
			-- TODO: error sound or flash or something
		end
	end
end
