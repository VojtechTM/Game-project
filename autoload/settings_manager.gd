extends Node

const SAVE_PATH := "user://settings.cfg"

var audio := {
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"output_device": "Default",
}

var graphics := {
	"window_mode": 0,          # 0=okno 1=fullscreen 2=maximalizované
	"resolution": Vector2i(1280, 720),
	"vsync": true,
	"msaa": 0,                 # 0=off 1=2x 2=4x 3=8x
}

# action_name → keycode (kladné = Key, záporné = MouseButton index)
var controls: Dictionary = {}

const TRACKED_ACTIONS := [
	"move_forward", "move_back", "move_left", "move_right",
	"jump", "sprint", "interact", "toggle_inventory",
	"shoot", "reload",
]

func _ready() -> void:
	_init_controls()
	load_settings()
	apply_all()

func _init_controls() -> void:
	for action in TRACKED_ACTIONS:
		if not InputMap.has_action(action):
			continue
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				controls[action] = int(event.keycode)
				break
			elif event is InputEventMouseButton:
				controls[action] = -(event as InputEventMouseButton).button_index
				break

func apply_all() -> void:
	apply_audio()
	apply_graphics()
	apply_controls()

func apply_audio() -> void:
	var master := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(
		master, linear_to_db(audio["master_volume"])
	)

	var music := AudioServer.get_bus_index("Music")
	if music >= 0:
		AudioServer.set_bus_volume_db(
			music, linear_to_db(audio["music_volume"])
		)

	var sfx := AudioServer.get_bus_index("SFX")
	if sfx >= 0:
		AudioServer.set_bus_volume_db(
			sfx, linear_to_db(audio["sfx_volume"])
		)

	var devices := AudioServer.get_output_device_list()
	if audio["output_device"] in devices:
		AudioServer.output_device = audio["output_device"]

func apply_graphics() -> void:
	match graphics["window_mode"]:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

	if graphics["window_mode"] == 0:
		DisplayServer.window_set_size(graphics["resolution"])

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if graphics["vsync"]
		else DisplayServer.VSYNC_DISABLED
	)

	var msaa_map := [
		Viewport.MSAA_DISABLED,
		Viewport.MSAA_2X,
		Viewport.MSAA_4X,
		Viewport.MSAA_8X,
	]
	get_viewport().msaa_3d = msaa_map[graphics["msaa"]]

func apply_controls() -> void:
	for action in controls:
		if not InputMap.has_action(action):
			continue
		InputMap.action_erase_events(action)
		var code: int = controls[action]
		if code < 0:
			var ev := InputEventMouseButton.new()
			ev.button_index = -code
			InputMap.action_add_event(action, ev)
		else:
			var ev := InputEventKey.new()
			ev.keycode = code
			InputMap.action_add_event(action, ev)

func save_settings() -> void:
	var cfg := ConfigFile.new()
	for k in audio:
		cfg.set_value("audio", k, audio[k])
	for k in graphics:
		cfg.set_value("graphics", k, graphics[k])
	for k in controls:
		cfg.set_value("controls", k, controls[k])
	cfg.save(SAVE_PATH)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	for k in audio:
		audio[k] = cfg.get_value("audio", k, audio[k])
	for k in graphics:
		graphics[k] = cfg.get_value("graphics", k, graphics[k])
	for k in controls:
		controls[k] = cfg.get_value("controls", k, controls[k])
