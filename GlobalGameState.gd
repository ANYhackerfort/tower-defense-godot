extends Node

var data: int = 10
var ram: int = 100
var selected_tower_scene: PackedScene = null

# Remeber what playerw as holding so could refund it 
# if choose to select some other tower
var selected_tower_cost: int = 0

signal ram_changed(new_amount)
signal data_changed(new_data)

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
	
func take_base_damage(damage_to_base) -> void:
	data -= damage_to_base
	if data <= 0:
		print("You Lose")
		get_tree().reload_current_scene()
		return
	else:
		data_changed.emit(data)
