extends Control

@onready var item_list: VBoxContainer = \
	$Panel/VBoxContainer/ScrollContainer/ItemList

func _ready() -> void:
	visible = false
	Inventory.ui_node = self
	Inventory.inventory_changed.connect(_refresh)

func _refresh() -> void:
	for child in item_list.get_children():
		child.queue_free()

	for i in Inventory.items.size():
		var data := Inventory.items[i]
		var row := HBoxContainer.new()

		var name_lbl := Label.new()
		name_lbl.text = data.get("name", "?")
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var desc_lbl := Label.new()
		desc_lbl.text = data.get("description", "")
		desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var btn := Button.new()
		btn.text = "Odhodit"
		var idx := i
		btn.pressed.connect(func(): Inventory.remove_item(idx))

		row.add_child(name_lbl)
		row.add_child(desc_lbl)
		row.add_child(btn)
		item_list.add_child(row)
