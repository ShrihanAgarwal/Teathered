# GameManager.gd
extends Node

signal wave_started(wave_number)
signal wave_completed(wave_number)
signal gold_changed(new_amount)
signal game_over()

var current_wave: int = 0
var shared_gold: int = 0
var enemies_remaining: int = 0
var players_alive: int = 0

# Define all waves here — add more as needed
const WAVES = [
	{"enemies": 5,  "type": "crawler", "boss": false},
	{"enemies": 8,  "type": "crawler", "boss": false},
	{"enemies": 6,  "type": "ranged",  "boss": true},
	{"enemies": 10, "type": "ranged",  "boss": false},
	{"enemies": 8,  "type": "crawler", "boss": true},
]

func start_next_wave():
	current_wave += 1
	if current_wave > WAVES.size():
		print("You Win!")
		return
	emit_signal("wave_started", current_wave)
	enemies_remaining = WAVES[current_wave - 1]["enemies"]

func enemy_killed(gold_reward: int):
	enemies_remaining -= 1
	add_gold(gold_reward)
	if enemies_remaining <= 0:
		emit_signal("wave_completed", current_wave)

func add_gold(amount: int):
	shared_gold += amount
	emit_signal("gold_changed", shared_gold)

func spend_gold(amount: int) -> bool:
	if shared_gold >= amount:
		shared_gold -= amount
		emit_signal("gold_changed", shared_gold)
		return true
	return false

func player_died(id: int):
	players_alive -= 1
	if players_alive <= 0:
		emit_signal("game_over")
