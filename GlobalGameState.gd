extends Node

var ram: int = 999
var selected_tower_scene: PackedScene = null
var unlocked_towers: Array[String] = []

# Remeber what playerw as holding so could refund it 
# if choose to select some other tower
var selected_tower_cost: int = 0

signal ram_changed(new_amount)

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
