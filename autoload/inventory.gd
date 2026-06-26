# autoload/inventory.gd
extends Node

signal inventory_changed

const MAX_SLOTS := 20
var ui_node: Control = null

## Slot = { item: Item, quantity: int }
var slots: Array[Dictionary] = []

func add_item(item: Item, quantity: int = 1) -> bool:
	# Zkus stackovat
	if item.max_stack > 1:
		for slot in slots:
			if (slot["item"] as Item).id == item.id:
				var current_qty := slot["quantity"] as int
				if current_qty < item.max_stack:
					var space: int = item.max_stack - current_qty
					var add: int = mini(quantity, space)
					slot["quantity"] = current_qty + add
					quantity -= add
					if quantity <= 0:
						inventory_changed.emit()
						return true

	# Nový slot
	while quantity > 0:
		if slots.size() >= MAX_SLOTS:
			print("Inventář plný!")
			return false
		var stack: int = mini(quantity, item.max_stack)
		slots.append({ "item": item, "quantity": stack })
		quantity -= stack

	inventory_changed.emit()
	return true

func remove_item(index: int, quantity: int = 1) -> void:
	if index < 0 or index >= slots.size():
		return
	var current_qty := slots[index]["quantity"] as int
	slots[index]["quantity"] = current_qty - quantity
	if (slots[index]["quantity"] as int) <= 0:
		slots.remove_at(index)
	inventory_changed.emit()

func use_item(index: int, player: Node) -> void:
	if index < 0 or index >= slots.size():
		return
	var item := slots[index]["item"] as Item
	var consumed := item.use(player)
	if consumed:
		remove_item(index, 1)

func toggle_ui() -> void:
	if not ui_node:
		return
	ui_node.visible = not ui_node.visible
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if ui_node.visible
		else Input.MOUSE_MODE_CAPTURED
	)
