# scripts/inventory_slot.gd
extends Button

var _pending_item: Item = null
var _pending_quantity: int = 0
var _pending_selected: bool = false
var _is_empty: bool = true

func set_data(item: Item, quantity: int, selected: bool) -> void:
	_pending_item = item
	_pending_quantity = quantity
	_pending_selected = selected
	_is_empty = false
	if is_node_ready():
		_apply()

func set_empty(selected: bool) -> void:
	_pending_item = null
	_pending_selected = selected
	_is_empty = true
	if is_node_ready():
		_apply()

func _ready() -> void:
	_apply()

func _apply() -> void:
	var item_icon: TextureRect = \
		$MarginContainer/VBoxContainer/Icon
	var qty_label: Label = \
		$MarginContainer/VBoxContainer/QuantityLabel

	if _is_empty or _pending_item == null:
		item_icon.texture = null
		qty_label.text = ""
		tooltip_text = ""
	else:
		item_icon.texture = _pending_item.icon
		qty_label.text = "×%d" % _pending_quantity \
			if _pending_quantity > 1 else ""
		tooltip_text = _pending_item.get_tooltip()

	_set_selected(_pending_selected)

func _set_selected(selected: bool) -> void:
	if selected:
		add_theme_stylebox_override(
			"normal", _make_style(Color(0.3, 0.6, 1.0, 0.3))
		)
	else:
		remove_theme_stylebox_override("normal")

func _make_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left   = 2
	style.border_width_right  = 2
	style.border_width_top    = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.6, 1.0, 0.8)
	return style
