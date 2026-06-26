# resources/items/consumable_item.gd
class_name ConsumableItem
extends Item

@export var heal_amount: int = 0
@export var hunger_restore: float = 0.0
@export var thirst_restore: float = 0.0
@export var use_time: float = 1.5   # sekundy animace

func _init() -> void:
	category = Category.CONSUMABLE
	max_stack = 5

func use(player: Node) -> bool:
	if heal_amount > 0 and player.has_method("heal"):
		player.heal(heal_amount)
	return true  # spotřebovat
