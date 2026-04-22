extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_radius: float = 12.0

func _ready():
	GameManager.wave_started.connect(_on_wave_started)

func _on_wave_started(wave_number: int):
	print("Wave ", wave_number, " starting!")
	var wave_data = GameManager.WAVES[wave_number - 1]
	var count = wave_data["enemies"]

	for i in count:
		# Small delay between each enemy spawn
		await get_tree().create_timer(0.8 * i).timeout
		_spawn_enemy()

func _spawn_enemy():
	if enemy_scene == null:
		print("ERROR: No enemy scene assigned to EnemySpawner!")
		return

	var enemy = enemy_scene.instantiate()

	# Spawn in a ring around the arena
	var angle = randf() * TAU
	var pos = Vector3(cos(angle) * spawn_radius, 1, sin(angle) * spawn_radius)
	enemy.global_position = pos

	get_parent().add_child(enemy)
	print("Enemy spawned at ", pos)
