# scripts/world_item.gd
extends StaticBody3D

@export var item: Item = null
@export var quantity: int = 1

@onready var label: Label3D = $Label3D

func _ready() -> void:
	if item:
		label.text = "[E] %s" % item.display_name
	else:
		label.text = "[E] ?"

func interact(_player: Node) -> void:
	if not item:
		push_warning("WorldItem nemá přiřazený item resource!")
		return
	Inventory.add_item(item, quantity)
	queue_free()
