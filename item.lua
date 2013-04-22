function newItem(name, pic, description, price)
	local new_item = {}
	setmetatable(new_item, {__index = item})

	new_item.name = name
	new_item.pic = pic
	new_item.descr = description
	new_item.price = price

	return new_item
end
