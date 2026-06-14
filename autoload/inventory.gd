# autoload/inventory.gd
extends Node

signal inventory_changed

const MAX_SLOTS := 20
var items: Array[Dictionary] = []
var ui_node: Control = null

func add_item(data: Dictionary) -> bool:
	if items.size() >= MAX_SLOTS:
		print("Inventář je plný!")
		return false
	items.append(data)
	inventory_changed.emit()
	return true

func remove_item(index: int) -> void:
	if index >= 0 and index < items.size():
		items.remove_at(index)
		inventory_changed.emit()

func toggle_ui() -> void:
	if not ui_node:
		return
	ui_node.visible = not ui_node.visible
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if ui_node.visible
		else Input.MOUSE_MODE_CAPTURED
	)
