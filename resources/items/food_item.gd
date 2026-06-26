# resources/items/food_item.gd
class_name FoodItem
extends ConsumableItem

@export var spoil_time: float = -1.0  # -1 = nekazí se

func _init() -> void:
	category = Category.CONSUMABLE
	max_stack = 5
	weight = 0.3
