# resources/items/note_item.gd
class_name NoteItem
extends Item

@export_multiline var content: String = ""
@export var author: String = ""
@export var handwritten: bool = true

func _init() -> void:
	category = Category.NOTE
	max_stack = 1
	weight = 0.01

func use(player: Node) -> bool:
	if player.has_method("read_note"):
		player.read_note(self)
	return false  # note se nesmaže po přečtení
