export ^

class Item
    new: (@name, @pic, @description, @price) =>

class HealthPotion extends Item
    new: =>
        super("Health Potion", picItemPlaceHolder, "Fill one heart", 100)

class EagleEye extends Item
    new: =>
        super("Eagle eye", picItemPlaceHolder, "Bigger attack radius", 200)
