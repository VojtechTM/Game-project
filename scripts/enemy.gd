extends CharacterBody3D

enum State { IDLE, CHASE, ATTACK }

const SPEED := 3.0
const DETECTION_RANGE := 12.0
const ATTACK_RANGE := 1.8
const ATTACK_DAMAGE := 10
const ATTACK_COOLDOWN := 1.5

@export var health := 50

var state := State.IDLE
var player: CharacterBody3D = null
var attack_timer := 0.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	await get_tree().physics_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	attack_timer = max(0.0, attack_timer - delta)
	_update_state()
	_process_state()
	move_and_slide()

func _update_state() -> void:
	if not player:
		return
	var dist := global_position.distance_to(player.global_position)
	if dist <= ATTACK_RANGE:
		state = State.ATTACK
	elif dist <= DETECTION_RANGE:
		state = State.CHASE
	else:
		state = State.IDLE

func _process_state() -> void:
	match state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, SPEED)
			velocity.z = move_toward(velocity.z, 0.0, SPEED)

		State.CHASE:
			var dir := player.global_position - global_position
			dir.y = 0.0
			dir = dir.normalized()
			velocity.x = dir.x * SPEED
			velocity.z = dir.z * SPEED
			look_at(
				Vector3(
					player.global_position.x,
					global_position.y,
					player.global_position.z
				),
				Vector3.UP
			)

		State.ATTACK:
			velocity.x = move_toward(velocity.x, 0.0, SPEED)
			velocity.z = move_toward(velocity.z, 0.0, SPEED)
			if attack_timer == 0.0:
				attack_timer = ATTACK_COOLDOWN
				if player.has_method("take_damage"):
					player.take_damage(ATTACK_DAMAGE)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
