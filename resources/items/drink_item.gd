# resources/items/drink_item.gd
class_name DrinkItem
extends ConsumableItem

@export var volume_ml: int = 500

func _init() -> void:
	category = Category.CONSUMABLE
	max_stack = 3
	weight = 0.5
