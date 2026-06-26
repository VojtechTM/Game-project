# resources/items/tool_item.gd
class_name ToolItem
extends Item

enum ToolType { SCREWDRIVER, PLIERS, TAPE, GENERIC }

@export var tool_type: ToolType = ToolType.GENERIC
@export var durability: int = 100

func _init() -> void:
	category = Category.TOOL
	max_stack = 1
	weight = 0.4
