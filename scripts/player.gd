extends CharacterBody3D

const SPEED := 5.0
const SPRINT_SPEED := 8.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.002

@export var max_health := 100
var health := max_health

@onready var head: Node3D = $Head
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")

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

func _try_interact() -> void:
	if interact_ray.is_colliding():
		var col := interact_ray.get_collider()
		if col.has_method("interact"):
			col.interact(self)

func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	print("HP: %d / %d" % [health, max_health])
	if health == 0:
		get_tree().reload_current_scene()
