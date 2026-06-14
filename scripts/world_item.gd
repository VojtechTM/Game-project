extends StaticBody3D

@export var item_name: String = "Předmět"
@export var item_description: String = ""

@onready var label: Label3D = $Label3D

func _ready() -> void:
	label.text = "[E] " + item_name

func interact(_player: Node) -> void:
	Inventory.add_item({
		"name": item_name,
		"description": item_description,
	})
	queue_free()
