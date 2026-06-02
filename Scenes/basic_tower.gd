extends Node2D

@export var cost: int = 50
@export var damage: int = 1
@export var fire_rate: float = 1.0
@export var tower_range: float = 150.0

@onready var placement_box: Polygon2D = $PlacementBox
@onready var shoot_timer: Timer = $ShootTimer

var is_ghost: bool = false

func _ready() -> void:
	if placement_box == null:
		return

	placement_box.polygon = PackedVector2Array([
		Vector2(-64, -64),
		Vector2(64, -64),
		Vector2(64, 64),
		Vector2(-64, 64)
	])

	if is_ghost:
		set_as_ghost(true)
		return

	add_to_group("placed_towers")

	placement_box.visible = false

	if shoot_timer:
		shoot_timer.wait_time = fire_rate
		shoot_timer.start()

func set_as_ghost(value: bool) -> void:
	is_ghost = value

	if placement_box == null:
		return

	if is_ghost:
		modulate = Color(1, 1, 1, 0.55)
		placement_box.visible = true
	else:
		modulate = Color(1, 1, 1, 1)
		placement_box.visible = false

func set_can_place(value: bool) -> void:
	if placement_box == null:
		return

	if value:
		placement_box.color = Color(0, 1, 0, 0.25)
	else:
		placement_box.color = Color(1, 0, 0, 0.25)

func get_cost() -> int:
	return cost
