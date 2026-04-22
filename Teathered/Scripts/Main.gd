extends Node3D

func _ready():
	# Find both players
	var p1 = $Player
	var p2 = $Player2

	# Connect the chain between them
	var chain = $Chain
	chain.setup(p1, p2)

	# Tell GameManager how many players there are
	GameManager.players_alive = 2

	# Listen for game over
	GameManager.game_over.connect(_on_game_over)
	GameManager.wave_completed.connect(_on_wave_completed)

	# Start wave 1
	GameManager.start_next_wave()

func _on_wave_completed(wave_num):
	print("Wave ", wave_num, " complete! Gold: ", GameManager.shared_gold)
	# Small delay then start next wave
	await get_tree().create_timer(3.0).timeout
	GameManager.start_next_wave()

func _on_game_over():
	print("GAME OVER!")
	# We'll add a proper game over screen later
