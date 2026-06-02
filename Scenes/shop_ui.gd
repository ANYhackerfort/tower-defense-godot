extends CanvasLayer

@export var basic_tower_scene: PackedScene
@export var cannon_tower_scene: PackedScene

@onready var ram_label: Label = $Panel/RamLabel
@onready var tower_list: VBoxContainer = $Panel/TowerList

var towers: Array[Dictionary] = []

func _ready() -> void:
	towers = [
		{
			"name": "Basic Tower",
			"cost": 50,
			"scene": basic_tower_scene
		},
		{
			"name": "Cannon Tower",
			"cost": 100,
			"scene": cannon_tower_scene
		}
	]

	# TEMP TEST MONEY
	GlobalGameState.add_ram(999)

	update_ram_label()
	GlobalGameState.ram_changed.connect(_on_ram_changed)

	create_tower_buttons()

func _on_ram_changed(new_amount: int) -> void:
	ram_label.text = "Gold: " + str(new_amount)
	update_button_states()

func update_ram_label() -> void:
	ram_label.text = "Gold: " + str(GlobalGameState.ram)

func create_tower_buttons() -> void:
	for tower in towers:
		var button := Button.new()

		button.text = tower["name"] + "\nCost: " + str(tower["cost"]) + " Gold"
		button.custom_minimum_size = Vector2(180, 70)

		button.pressed.connect(func():
			buy_tower(tower)
		)

		tower_list.add_child(button)

	update_button_states()

func update_button_states() -> void:
	for i in range(tower_list.get_child_count()):
		var button := tower_list.get_child(i) as Button
		var tower := towers[i]

		button.disabled = GlobalGameState.ram < tower["cost"]

func buy_tower(tower: Dictionary) -> void:
	var cost: int = tower["cost"]
	var scene: PackedScene = tower["scene"]

	# refund whatever tower the player is currently holding
	GlobalGameState.refund_selected_tower()

	if GlobalGameState.spend_ram(cost):
		GlobalGameState.select_tower(scene, cost)
