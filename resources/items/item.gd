# resources/items/item.gd
class_name Item
extends Resource

enum Category {
	CONSUMABLE,
	WEAPON,
	AMMO,
	KEY,
	TOOL,
	STORAGE,
	NOTE,
}

@export var id: StringName = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var category: Category = Category.CONSUMABLE
@export var max_stack: int = 1
@export var weight: float = 0.1

## Volá se při použití itemu z inventáře
## Vrací true pokud byl item spotřebován (odebrat ze slotu)
func use(player: Node) -> bool:
	return false

func get_tooltip() -> String:
	return "%s\n%s" % [display_name, description]
