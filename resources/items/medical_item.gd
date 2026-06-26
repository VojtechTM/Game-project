# resources/items/medical_item.gd
class_name MedicalItem
extends ConsumableItem

@export var stop_bleeding: bool = false
@export var apply_time: float = 3.0

func _init() -> void:
	category = Category.CONSUMABLE
	max_stack = 5
	weight = 0.2
