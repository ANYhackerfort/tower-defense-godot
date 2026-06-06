extends Node2D

var source_scene: PackedScene = load("res://Scenes/FirewallTower.tscn")

@export var cost: int = 80
@export var damage: int = 2

@onready var placement_box: Polygon2D = $PlacementBox
@onready var shoot_timer: Timer = $ShootTimer
@onready var range_area: Area2D = $AttackRange
@onready var range_shape: CollisionShape2D = $AttackRange/CollisionShape2D
@onready var pickup_area: Area2D = $PickupRange

@onready var spawn_point: Node2D = $AttackSpawn

var is_ghost: bool = false
var targets_in_range: Array[Area2D] = []

func _ready() -> void:
	placement_box.polygon = PackedVector2Array([
		Vector2(-64, -64),
		Vector2(64, -64),
		Vector2(64, 64),
		Vector2(-64, 64)
	])

	if is_ghost:
		modulate = Color(1, 1, 1, 0.55)
		placement_box.visible = true
		range_area.monitoring = false
		pickup_area.monitoring = false 
		queue_redraw()
		return

	add_to_group("placed_towers")
	placement_box.visible = false
	range_area.monitoring = true

	pickup_area.monitoring = true
	pickup_area.body_entered.connect(_on_player_entered_pickup)
	pickup_area.body_exited.connect(_on_player_exited_pickup)

	range_area.area_entered.connect(_on_enemy_entered)
	range_area.area_exited.connect(_on_enemy_exited)

	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	if not shoot_timer.autostart:
		shoot_timer.start()

func _process(_delta: float) -> void:
	if not is_ghost and get_current_target() != null:
		queue_redraw()

func set_can_place(value: bool) -> void:
	if value:
		placement_box.color = Color(0, 1, 0, 0.25)
	else:
		placement_box.color = Color(1, 0, 0, 0.25)

func _draw() -> void:
	if is_ghost:
		var radius: float = range_shape.shape.radius
		var fill_color := Color(0, 0.5, 1, 0.1)
		draw_circle(Vector2.ZERO, radius, fill_color)
		var line_color := Color(0, 0.6, 1, 0.4)
		var line_thickness: float = 2.0
		draw_arc(Vector2.ZERO, radius, 0, TAU, 64, line_color, line_thickness, true)
		return
		
	var target := get_current_target()
	if target != null:
		var local_start_pos := to_local(spawn_point.global_position)
		var local_target_pos := to_local(target.global_position)
		
		var beam_glow_color := Color(1.0, 0.2, 0.0, 0.6)
		var glow_thickness: float = 6.0
		draw_line(local_start_pos, local_target_pos, beam_glow_color, glow_thickness, true)
		
		var beam_core_color := Color(1.0, 1.0, 1.0, 0.9)
		var core_thickness: float = 2.0
		draw_line(local_start_pos, local_target_pos, beam_core_color, core_thickness, true)

func get_cost() -> int:
	return cost

# --- PICKUP RANGE LOGIC ---

func _on_player_entered_pickup(body: Node2D) -> void:
	if body.is_in_group("player"):
		add_to_group("player_can_pickup")

func _on_player_exited_pickup(body: Node2D) -> void:
	if body.is_in_group("player"):
		remove_from_group("player_can_pickup")

# --- TARGETING LOGIC ---

func _on_enemy_entered(enemy_hitbox: Area2D) -> void:
	if enemy_hitbox.owner.is_in_group("enemies"):
		targets_in_range.append(enemy_hitbox)

func _on_enemy_exited(enemy_hitbox: Area2D) -> void:
	targets_in_range.erase(enemy_hitbox)
	
	if not is_ghost:
		queue_redraw()

func get_current_target() -> Node2D:
	while not targets_in_range.is_empty():
		var target_hitbox = targets_in_range[0]
		
		if is_instance_valid(target_hitbox) and target_hitbox.is_inside_tree():
			return target_hitbox.owner as Node2D
		else:
			targets_in_range.pop_front()
			
	return null
	
func _on_shoot_timer_timeout() -> void:
	var target := get_current_target()
	if target != null:
		shoot(target)

func shoot(target: Node2D) -> void:
	target.take_damage(damage)
