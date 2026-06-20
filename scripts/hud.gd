# scripts/hud.gd
extends CanvasLayer

@onready var health_bar: ProgressBar = \
	$Control/BottomLeft/HealthBar
@onready var health_label: Label = \
	$Control/BottomLeft/HealthLabel
@onready var ammo_label: Label = \
	$Control/BottomRight/AmmoLabel
@onready var reload_label: Label = \
	$Control/BottomRight/ReloadLabel

func _ready() -> void:
	await get_tree().physics_frame
	var player: Node = get_tree().get_first_node_in_group("player")
	if not player:
		return

	health_bar.max_value = player.max_health
	health_bar.value = player.health
	_on_ammo_changed(player.ammo, player.max_ammo)

	player.health_changed.connect(_on_health_changed)
	player.ammo_changed.connect(_on_ammo_changed)
	player.reload_started.connect(_on_reload_started)
	player.reload_finished.connect(_on_reload_finished)

func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.value = current
	health_label.text = "HP: %d / %d" % [current, maximum]

func _on_ammo_changed(current: int, maximum: int) -> void:
	ammo_label.text = "%d / %d" % [current, maximum]

func _on_reload_started() -> void:
	reload_label.visible = true

func _on_reload_finished() -> void:
	reload_label.visible = false
