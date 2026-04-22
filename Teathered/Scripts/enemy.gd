extends CharacterBody3D

@export var speed: float = 3.0
@export var health: float = 30.0
@export var damage: float = 10.0
@export var gold_reward: int = 5
@export var attack_range: float = 1.5
@export var attack_cooldown: float = 1.0

var target: Node3D = null
var attack_timer: float = 0.0

const GRAVITY = -20.0

func _ready():
	add_to_group("enemies")
	_find_target()

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	attack_timer -= delta

	if target == null:
		_find_target()
		move_and_slide()
		return

	# Move toward target
	var direction = (target.global_position - global_position)
	direction.y = 0
	direction = direction.normalized()

	var dist = global_position.distance_to(target.global_position)

	if dist > attack_range:
		# Chase the player
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		# Stop and attack
		velocity.x = 0
		velocity.z = 0
		if attack_timer <= 0:
			attack_timer = attack_cooldown
			print("Enemy attacked player for ", damage, " damage!")

	move_and_slide()

func _find_target():
	# Find the closest player
	var players = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return
	var closest_dist = INF
	for p in players:
		var d = global_position.distance_to(p.global_position)
		if d < closest_dist:
			closest_dist = d
			target = p

func take_damage(amount: float):
	health -= amount
	print("Enemy health: ", health)
	if health <= 0:
		die()

func die():
	GameManager.enemy_killed(gold_reward)
	queue_free()
