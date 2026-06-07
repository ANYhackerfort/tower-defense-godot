extends Node

var data: int = 10
var ram: int = 100
var selected_tower_scene: PackedScene = null
var selected_tower_cost: int = 0

signal ram_changed(new_amount)
signal data_changed(new_data)
signal game_over
signal victory

func setup_level(starting_ram: int, starting_data: int = 10) -> void:
	data = starting_data
	ram = starting_ram
	selected_tower_scene = null
	selected_tower_cost = 0
	
	ram_changed.emit(ram)
	data_changed.emit(data)

func add_ram(amount: int) -> void:
	ram += amount
	ram_changed.emit(ram)

func spend_ram(amount: int) -> bool:
	if ram < amount:
		return false
	
	ram -= amount
	ram_changed.emit(ram)
	return true

func select_tower(tower_scene: PackedScene, tower_cost: int) -> void:
	selected_tower_scene = tower_scene
	selected_tower_cost = tower_cost

func refund_selected_tower() -> void:
	if selected_tower_scene != null:
		add_ram(selected_tower_cost)

	selected_tower_scene = null
	selected_tower_cost = 0
	
func take_base_damage(damage_to_base: int) -> void:
	data -= damage_to_base
	data_changed.emit(data)
	if data <= 0:
		print("You Lose")
		game_over.emit()

func reset_game() -> void:
	selected_tower_scene = null
	selected_tower_cost = 0
	
	get_tree().paused = false 
	get_tree().reload_current_scene()

func next_level() -> void:
	selected_tower_scene = null
	selected_tower_cost = 0
	
	get_tree().paused = false
