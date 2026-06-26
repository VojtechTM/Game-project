# resources/items/melee_item.gd
class_name MeleeItem
extends Item

@export var damage: int = 35
@export var attack_time: float = 0.6
@export var reach: float = 1.8

func _init() -> void:
	category = Category.WEAPON
	max_stack = 1
	weight = 0.8

func use(_player: Node) -> bool:
	return false
