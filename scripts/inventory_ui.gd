# scripts/inventory_ui.gd
extends Control

const MAX_WEIGHT := 20.0
const SLOT_SCENE := preload("res://scenes/inventory_slot.tscn")

var _selected_index: int = -1

@onready var grid: GridContainer = \
	$PanelContainer/MarginContainer/VBoxContainer/Grid
@onready var weight_label: Label = \
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/WeightLabel
@onready var detail_icon: TextureRect = \
	$PanelContainer/MarginContainer/VBoxContainer/ItemDetail/DetailIcon
@onready var detail_name: Label = \
	$PanelContainer/MarginContainer/VBoxContainer/ItemDetail/VBoxContainer/DetailName
@onready var detail_desc: Label = \
	$PanelContainer/MarginContainer/VBoxContainer/ItemDetail/VBoxContainer/DetailDesc
@onready var btn_use: Button = \
	$PanelContainer/MarginContainer/VBoxContainer/ItemDetail/VBoxContainer2/BtnUse
@onready var btn_drop: Button = \
	$PanelContainer/MarginContainer/VBoxContainer/ItemDetail/VBoxContainer2/BtnDrop

func _ready() -> void:
	visible = false
	Inventory.ui_node = self
	Inventory.inventory_changed.connect(_refresh)
	btn_use.pressed.connect(_on_use)
	btn_drop.pressed.connect(_on_drop)
	_clear_detail()

func _refresh() -> void:
	# Vyčisti grid
	for child in grid.get_children():
		child.queue_free()

	# Prázdné sloty vždy 20
	for i in Inventory.MAX_SLOTS:
		var slot_node: Control = SLOT_SCENE.instantiate()
		if i < Inventory.slots.size():
			var slot := Inventory.slots[i]
			slot_node.set_data(
				slot["item"] as Item,
				slot["quantity"] as int,
				i == _selected_index
			)
			slot_node.pressed.connect(_on_slot_pressed.bind(i))
		else:
			slot_node.set_empty(i == _selected_index)
			slot_node.pressed.connect(_on_slot_pressed.bind(i))
		grid.add_child(slot_node)

	# Váha
	var total_weight := 0.0
	for slot in Inventory.slots:
		total_weight += (slot["item"] as Item).weight \
			* (slot["quantity"] as int)
	weight_label.text = "%.1f / %.1f kg" % [total_weight, MAX_WEIGHT]

	# Ověř že selected index je stále platný
	if _selected_index >= Inventory.slots.size():
		_selected_index = -1
		_clear_detail()
	elif _selected_index >= 0:
		_show_detail(_selected_index)

func _on_slot_pressed(index: int) -> void:
	if index >= Inventory.slots.size():
		_selected_index = -1
		_clear_detail()
		return

	_selected_index = index
	_show_detail(index)
	_refresh()

func _show_detail(index: int) -> void:
	var item := Inventory.slots[index]["item"] as Item
	var qty  := Inventory.slots[index]["quantity"] as int

	detail_name.text = "%s  ×%d" % [item.display_name, qty] \
		if qty > 1 else item.display_name
	detail_desc.text = item.description
	detail_icon.texture = item.icon

	# Skryj "Použít" pro věci co nejde použít ručně
	var usable_categories := [
		Item.Category.CONSUMABLE,
		Item.Category.NOTE,
		Item.Category.STORAGE,
	]
	btn_use.visible = item.category in usable_categories
	btn_drop.visible = item.category != Item.Category.NOTE

func _clear_detail() -> void:
	detail_name.text = ""
	detail_desc.text = ""
	detail_icon.texture = null
	btn_use.visible = false
	btn_drop.visible = false

func _on_use() -> void:
	if _selected_index < 0:
		return
	var player := get_tree().get_first_node_in_group("player")
	Inventory.use_item(_selected_index, player)
	# index mohl zmizet
	if _selected_index >= Inventory.slots.size():
		_selected_index = -1
		_clear_detail()

func _on_drop() -> void:
	if _selected_index < 0:
		return
	Inventory.remove_item(_selected_index, 1)
