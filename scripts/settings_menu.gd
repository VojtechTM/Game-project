# scripts/settings_menu.gd
extends Control

const SCENE_MENU := "res://scenes/main_menu.tscn"

const ACTION_LABELS := {
	"move_forward":     "Dopředu",
	"move_back":        "Dozadu",
	"move_left":        "Doleva",
	"move_right":       "Doprava",
	"jump":             "Skok",
	"sprint":           "Sprint",
	"interact":         "Interakce",
	"toggle_inventory": "Inventář",
	"shoot":            "Střelba",
	"reload":           "Přebít",
}

const RESOLUTIONS := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
]

var _rebinding: String = ""
var _rebind_buttons: Dictionary = {}

@onready var tab_container: TabContainer = \
	$CenterContainer/Panel/VBox/TabContainer

@onready var controls_list: VBoxContainer = \
	$CenterContainer/Panel/VBox/TabContainer/Controls/m/ScrollContainer/VBox

@onready var slider_master: HSlider = \
	$CenterContainer/Panel/VBox/TabContainer/Audio/VBox/Master/HSlider
@onready var slider_music: HSlider = \
	$CenterContainer/Panel/VBox/TabContainer/Audio/VBox/Music/HSlider
@onready var slider_sfx: HSlider = \
	$CenterContainer/Panel/VBox/TabContainer/Audio/VBox/SFX/HSlider
@onready var option_output: OptionButton = \
	$CenterContainer/Panel/VBox/TabContainer/Audio/VBox/Output/OptionButton

@onready var option_window: OptionButton = \
	$CenterContainer/Panel/VBox/TabContainer/Graphics/VBox/WindowMode/OptionButton
@onready var option_resolution: OptionButton = \
	$CenterContainer/Panel/VBox/TabContainer/Graphics/VBox/Resolution/OptionButton
@onready var check_vsync: CheckButton = \
	$CenterContainer/Panel/VBox/TabContainer/Graphics/VBox/VSync/CheckButton
@onready var option_msaa: OptionButton = \
	$CenterContainer/Panel/VBox/TabContainer/Graphics/VBox/MSAA/OptionButton

func _ready() -> void:
	tab_container.set_tab_title(0, "Ovládání")
	tab_container.set_tab_title(1, "Zvuk")
	tab_container.set_tab_title(2, "Grafika")

	_build_controls_tab()
	_populate_audio_devices()
	_load_audio_ui()
	_load_graphics_ui()

	slider_master.value_changed.connect(
		func(v: float) -> void:
			SettingsManager.audio["master_volume"] = v
			SettingsManager.apply_audio()
	)
	slider_music.value_changed.connect(
		func(v: float) -> void:
			SettingsManager.audio["music_volume"] = v
			SettingsManager.apply_audio()
	)
	slider_sfx.value_changed.connect(
		func(v: float) -> void:
			SettingsManager.audio["sfx_volume"] = v
			SettingsManager.apply_audio()
	)
	option_output.item_selected.connect(_on_output_selected)
	option_window.item_selected.connect(_on_window_selected)
	option_resolution.item_selected.connect(_on_resolution_selected)
	check_vsync.toggled.connect(
		func(v: bool) -> void:
			SettingsManager.graphics["vsync"] = v
			SettingsManager.apply_graphics()
	)
	option_msaa.item_selected.connect(
		func(v: int) -> void:
			SettingsManager.graphics["msaa"] = v
			SettingsManager.apply_graphics()
	)
	$CenterContainer/Panel/VBox/BtnBack.pressed.connect(_on_back)

# ── Controls ──────────────────────────────────────────────────────────────────

func _build_controls_tab() -> void:
	for action in ACTION_LABELS:
		var row := HBoxContainer.new()

		var lbl := Label.new()
		lbl.text = ACTION_LABELS[action]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var btn := Button.new()
		btn.text = _code_to_str(SettingsManager.controls.get(action, 0))
		btn.custom_minimum_size = Vector2(150, 0)
		btn.pressed.connect(_on_rebind.bind(action))

		_rebind_buttons[action] = btn
		row.add_child(lbl)
		row.add_child(btn)
		controls_list.add_child(row)

func _on_rebind(action: String) -> void:
	if not _rebinding.is_empty():
		_rebind_buttons[_rebinding].text = _code_to_str(
			SettingsManager.controls.get(_rebinding, 0)
		)
	_rebinding = action
	_rebind_buttons[action].text = "Stiskni klávesu..."

func _unhandled_input(event: InputEvent) -> void:
	if _rebinding.is_empty():
		return
	if not (event is InputEventKey or event is InputEventMouseButton):
		return

	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		_rebind_buttons[_rebinding].text = _code_to_str(
			SettingsManager.controls.get(_rebinding, 0)
		)
		_rebinding = ""
		return

	var code: int
	if event is InputEventKey:
		code = int((event as InputEventKey).keycode)
	else:
		code = -((event as InputEventMouseButton).button_index)

	SettingsManager.controls[_rebinding] = code
	_rebind_buttons[_rebinding].text = _code_to_str(code)
	_rebinding = ""
	SettingsManager.apply_controls()
	get_viewport().set_input_as_handled()

func _code_to_str(code: int) -> String:
	if code == 0:
		return "—"
	if code < 0:
		match -code:
			MOUSE_BUTTON_LEFT:   return "LMB"
			MOUSE_BUTTON_RIGHT:  return "RMB"
			MOUSE_BUTTON_MIDDLE: return "MMB"
			_: return "Mouse %d" % -code
	return OS.get_keycode_string(code)

# ── Audio ─────────────────────────────────────────────────────────────────────

func _populate_audio_devices() -> void:
	option_output.clear()
	for d in AudioServer.get_output_device_list():
		option_output.add_item(d)
	var cur: String = SettingsManager.audio["output_device"]
	var idx := AudioServer.get_output_device_list().find(cur)
	option_output.selected = max(idx, 0)

func _load_audio_ui() -> void:
	slider_master.value = SettingsManager.audio["master_volume"]
	slider_music.value  = SettingsManager.audio["music_volume"]
	slider_sfx.value    = SettingsManager.audio["sfx_volume"]

func _on_output_selected(index: int) -> void:
	var devices := AudioServer.get_output_device_list()
	if index < devices.size():
		SettingsManager.audio["output_device"] = devices[index]
		SettingsManager.apply_audio()

# ── Graphics ──────────────────────────────────────────────────────────────────

func _load_graphics_ui() -> void:
	option_window.selected  = SettingsManager.graphics["window_mode"]
	check_vsync.button_pressed = SettingsManager.graphics["vsync"]
	option_msaa.selected    = SettingsManager.graphics["msaa"]

	for i in RESOLUTIONS.size():
		var r: Vector2i = RESOLUTIONS[i]
		option_resolution.add_item("%d × %d" % [r.x, r.y])
		if r == SettingsManager.graphics["resolution"]:
			option_resolution.selected = i

func _on_window_selected(index: int) -> void:
	SettingsManager.graphics["window_mode"] = index
	SettingsManager.apply_graphics()

func _on_resolution_selected(index: int) -> void:
	SettingsManager.graphics["resolution"] = RESOLUTIONS[index]
	SettingsManager.apply_graphics()

# ── Nav ───────────────────────────────────────────────────────────────────────

func _on_back() -> void:
	SettingsManager.save_settings()
	get_tree().change_scene_to_file(SCENE_MENU)
