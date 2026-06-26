# resources/items/weapon_item.gd
class_name WeaponItem
extends Item

@export var damage: int = 25
@export var fire_rate: float = 0.12
@export var reload_time: float = 1.5
@export var magazine_size: int = 30
@export var ammo_type: StringName = ""   # odpovídá AmmoItem.id
@export var range: float = 50.0

func _init() -> void:
	category = Category.WEAPON
	max_stack = 1
	weight = 2.5

func use(_player: Node) -> bool:
	return false  # zbraň se nepoužívá klikem z inventáře
