extends Node3D

@export var max_length: float = 5.0
@export var pull_strength: float = 30.0

var player_a: Node3D = null
var player_b: Node3D = null
var mesh_instance: MeshInstance3D

func _ready():
	mesh_instance = $MeshInstance3D

func setup(pa: Node3D, pb: Node3D):
	player_a = pa
	player_b = pb

func _process(delta):
	# Extra safety — check everything before touching players
	if not _players_valid():
		return

	mesh_instance.visible = true

	var pos_a = player_a.global_position
	var pos_b = player_b.global_position

	_draw_chain(pos_a, pos_b)

	var dist = pos_a.distance_to(pos_b)

	if dist > max_length and dist > 0.01:
		var overshoot = dist - max_length
		var pull_force = overshoot * pull_strength * delta

		var dir_a = (pos_b - pos_a).normalized()
		var dir_b = (pos_a - pos_b).normalized()

		# Check player has apply_pull before calling it
		if player_a.has_method("apply_pull"):
			player_a.apply_pull(dir_a * pull_force)
		if player_b.has_method("apply_pull"):
			player_b.apply_pull(dir_b * pull_force)

func _players_valid() -> bool:
	# Check every possible way a player could be invalid
	if player_a == null or player_b == null:
		return false
	if not is_instance_valid(player_a):
		return false
	if not is_instance_valid(player_b):
		return false
	if not player_a.is_inside_tree():
		return false
	if not player_b.is_inside_tree():
		return false
	return true

func _draw_chain(from: Vector3, to: Vector3):
	# Wrap in a try-safe way using a distance check
	var length = from.distance_to(to)
	if length < 0.1:
		mesh_instance.visible = false
		return

	mesh_instance.visible = true

	var mid = (from + to) / 2.0
	global_position = mid

	var cyl = CylinderMesh.new()
	cyl.height = length
	cyl.top_radius = 0.05
	cyl.bottom_radius = 0.05
	mesh_instance.mesh = cyl

	var direction = (to - from).normalized()
	if direction.length() > 0.001:
		var up = Vector3.UP
		if abs(direction.dot(up)) > 0.99:
			up = Vector3.FORWARD
		mesh_instance.basis = Basis.looking_at(direction, up).rotated(Vector3.RIGHT, PI / 2)
