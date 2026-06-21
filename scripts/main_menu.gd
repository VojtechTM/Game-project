extends Control

const SCENE_DEMO := "res://scenes/demo/demo_room.tscn"
const SCENE_SETTINGS := "res://scenes/settings_menu.tscn"

@onready var btn_play: Button = \
	$CenterContainer/VBox/BtnPlay
@onready var btn_demo: Button = \
	$CenterContainer/VBox/BtnDemo
@onready var btn_settings: Button = \
	$CenterContainer/VBox/BtnSettings
@onready var btn_quit: Button = \
	$CenterContainer/VBox/BtnQuit

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	btn_play.disabled = true   # zatím nikam nevede
	btn_play.pressed.connect(_on_play)
	btn_demo.pressed.connect(_on_demo)
	btn_settings.pressed.connect(_on_settings)
	btn_quit.pressed.connect(_on_quit)

func _on_play() -> void:
	pass  # TODO: hlavní hra

func _on_demo() -> void:
	get_tree().change_scene_to_file(SCENE_DEMO)

func _on_settings() -> void:
	get_tree().change_scene_to_file(SCENE_SETTINGS)

func _on_quit() -> void:
	get_tree().quit()
