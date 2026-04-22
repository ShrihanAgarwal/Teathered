extends CharacterBody3D

@export var speed: float = 5.0
@export var max_health: float = 100.0

var health: float = max_health
var is_dead: bool = false
var pull_velocity: Vector3 = Vector3.ZERO

const GRAVITY = -20.0

func _physics_process(delta):
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_forward", "move_backward")

	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Safely add pull force
	if pull_velocity.length() > 0.01:
		velocity.x += pull_velocity.x
		velocity.z += pull_velocity.z
		pull_velocity = pull_velocity.lerp(Vector3.ZERO, 0.3)
	else:
		pull_velocity = Vector3.ZERO

	move_and_slide()

func apply_pull(force: Vector3):
	if is_dead:
		return
	# Cap the pull force so it never gets insanely large
	var capped_force = force.limit_length(20.0)
	pull_velocity += capped_force

func take_damage(amount: float):
	if is_dead:
		return
	health -= amount
	print("Player health: ", health)
	if health <= 0:
		die()

func die():
	if is_dead:
		return
	is_dead = true
	print("Player died!")
	GameManager.player_died(0)
	visible = false
	if has_node("CollisionShape3D"):
		$CollisionShape3D.disabled = true

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_attack()

func _attack():
	print("Player attacked!")
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if global_position.distance_to(e.global_position) < 2.5:
			e.take_damage(25.0)
			print("Hit enemy!")
