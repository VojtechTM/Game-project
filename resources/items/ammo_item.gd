# resources/items/ammo_item.gd
class_name AmmoItem
extends Item

@export var caliber: String = "9mm"
@export var damage_modifier: float = 1.0

func _init() -> void:
	category = Category.AMMO
	max_stack = 60
	weight = 0.01
