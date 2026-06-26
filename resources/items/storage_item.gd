# resources/items/storage_item.gd
class_name StorageItem
extends Item

@export var extra_slots: int = 6
@export var allowed_categories: Array[Item.Category] = [
	Item.Category.TOOL
]

func _init() -> void:
	category = Category.STORAGE
	max_stack = 1
	weight = 2.0

func use(player: Node) -> bool:
	# TODO: otevřít sub-inventář
	return false
