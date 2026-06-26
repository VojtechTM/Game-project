# resources/items/key_item.gd
class_name KeyItem
extends Item

## ID se musí shodovat s DoorLock.required_key_id
@export var unlocks_id: StringName = ""
@export var single_use: bool = false

func _init() -> void:
	category = Category.KEY
	max_stack = 1
	weight = 0.05

func use(player: Node) -> bool:
	# Logiku zamykání řeší InteractRay → door
	return false
