extends CanvasLayer

# You can now drag and drop your .tres files directly into this array in the inspector!
@export var towers: Array[TowerData] = []

@onready var ram_label: Label = $RamLabel
@onready var data_label: Label = $DataLabel

@onready var tower_list: VBoxContainer = $ShopUI/TowerList

func _ready() -> void:
	update_ram_label()
	update_data_label()
	GlobalGameState.ram_changed.connect(_on_ram_changed)
	GlobalGameState.data_changed.connect(_on_data_changed)

	create_tower_buttons()

func _on_ram_changed(new_amount: int) -> void:
	ram_label.text = "RAM: " + str(new_amount)
	update_button_states()
	
func _on_data_changed(new_data:int) ->void:
		data_label.text = "DATA: " + str(new_data);

func update_ram_label() -> void:
	ram_label.text = "RAM: " + str(GlobalGameState.ram)

func update_data_label() -> void:
	data_label.text = "DATA: " + str(GlobalGameState.data);


func create_tower_buttons() -> void:
	# Clear any editor placeholders
	for child in tower_list.get_children():
		child.queue_free()

	for tower in towers:
		var button := Button.new()
		
		# Look mom, dot notation autocomplete! No more string keys.
		button.text = tower.name + "\nCost: " + str(tower.cost) + " RAM"
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

		button.disabled = GlobalGameState.ram < tower.cost

func buy_tower(tower: TowerData) -> void:
	# Refund whatever tower the player is currently holding
	GlobalGameState.refund_selected_tower()

	if GlobalGameState.spend_ram(tower.cost):
		GlobalGameState.select_tower(tower.scene, tower.cost)
