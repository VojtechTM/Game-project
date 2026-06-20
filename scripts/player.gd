# scripts/player.gd
extends CharacterBody3D

const SPEED := 5.0
const SPRINT_SPEED := 8.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.002
const FIRE_RATE := 0.12
const RELOAD_TIME := 1.5
const GUN_DAMAGE := 25

@export var max_health := 100
@export var max_ammo := 30

var health := max_health
var ammo := max_ammo
var is_reloading := false
var fire_timer := 0.0
var reload_timer := 0.0

signal health_changed(current: int, maximum: int)
signal ammo_changed(current: int, maximum: int)
signal reload_started
signal reload_finished

@onready var head: Node3D = $Head
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay
@onready var gun_ray: RayCast3D = $Head/Camera3D/GunRay
@onready var muzzle_flash: OmniLight3D = \
	$Head/Camera3D/GunMesh/MuzzleFlash

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	muzzle_flash.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and \
			Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, -PI / 2.0, PI / 2.0)

	if event.is_action_pressed("ui_cancel"):
		var captured := Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		Input.set_mouse_mode(
			Input.MOUSE_MODE_VISIBLE if captured
			else Input.MOUSE_MODE_CAPTURED
		)

	if event.is_action_pressed("interact"):
		_try_interact()

	if event.is_action_pressed("toggle_inventory"):
		Inventory.toggle_ui()

	if event.is_action_pressed("reload") and not is_reloading \
			and ammo < max_ammo:
		_start_reload()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	var direction := (
		transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	move_and_slide()

	# Timery
	fire_timer = max(0.0, fire_timer - delta)

	if reload_timer > 0.0:
		reload_timer -= delta
		if reload_timer <= 0.0:
			_finish_reload()

	# Střelba (držení = automatická)
	if Input.is_action_pressed("shoot") and \
			Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and \
			not is_reloading and fire_timer == 0.0:
		_shoot()

func _shoot() -> void:
	if ammo <= 0:
		_start_reload()
		return

	ammo -= 1
	fire_timer = FIRE_RATE
	ammo_changed.emit(ammo, max_ammo)

	# Záblesk
	muzzle_flash.visible = true
	get_tree().create_timer(0.05).timeout.connect(
		func(): muzzle_flash.visible = false
	)

	# Hit detection
	if gun_ray.is_colliding():
		var col := gun_ray.get_collider()
		if col.has_method("take_damage"):
			col.take_damage(GUN_DAMAGE)

func _start_reload() -> void:
	if is_reloading:
		return
	is_reloading = true
	reload_timer = RELOAD_TIME
	reload_started.emit()

func _finish_reload() -> void:
	is_reloading = false
	ammo = max_ammo
	ammo_changed.emit(ammo, max_ammo)
	reload_finished.emit()

func _try_interact() -> void:
	if interact_ray.is_colliding():
		var col := interact_ray.get_collider()
		if col.has_method("interact"):
			col.interact(self)

func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	health_changed.emit(health, max_health)
	if health == 0:
		get_tree().reload_current_scene()
