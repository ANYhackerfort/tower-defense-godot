extends Node2D

var source_scene: PackedScene = load("res://Scenes/DDoSPulsarTower.tscn")

@export var slow_factor: float = 0.3
@export var damage: int = 1       

@onready var placement_box: Polygon2D = $PlacementBox
@onready var shoot_timer: Timer = $ShootTimer
@onready var range_area: Area2D = $AttackRange
@onready var range_shape: CollisionShape2D = $AttackRange/CollisionShape2D
@onready var pickup_area: Area2D = $PickupRange

var is_ghost: bool = false
var targets_in_range: Array[Area2D] = []

var is_pulsing: bool = false
var pulse_progress: float = 0.0
@export var pulse_duration: float = 0.3

@onready var slow_meta_id: String = "ddos_slow_" + str(get_instance_id())

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

	# --- PLACED TOWER INITIALIZATION ---
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

func _process(delta: float) -> void:
	if is_pulsing:
		pulse_progress += delta / pulse_duration
		if pulse_progress >= 1.0:
			is_pulsing = false
			pulse_progress = 0.0
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
	
	if is_pulsing and not is_ghost:
		var max_radius: float = range_shape.shape.radius
		var current_radius := max_radius * pulse_progress
		
		var alpha := 1.0 - pulse_progress
		
		var ring_color := Color(0.0, 0.5, 1.0, alpha * 0.6)
		var ring_thickness: float = 4.0
		draw_arc(Vector2.ZERO, current_radius, 0, TAU, 64, ring_color, ring_thickness, true)
		
		var blast_fill := Color("#FF474C", alpha * 0.2)
		draw_circle(Vector2.ZERO, current_radius, blast_fill)

func _on_player_entered_pickup(body: Node2D) -> void:
	if body.is_in_group("player"):
		add_to_group("player_can_pickup")

func _on_player_exited_pickup(body: Node2D) -> void:
	if body.is_in_group("player"):
		remove_from_group("player_can_pickup")

func _on_enemy_entered(enemy_hitbox: Area2D) -> void:
	if enemy_hitbox.owner.is_in_group("enemies"):
		targets_in_range.append(enemy_hitbox)
		
		var enemy := enemy_hitbox.owner as Node2D
		if "speed" in enemy and not enemy.has_meta(slow_meta_id):
			enemy.set_meta(slow_meta_id, true)
			enemy.speed *= slow_factor

func _on_enemy_exited(enemy_hitbox: Area2D) -> void:
	targets_in_range.erase(enemy_hitbox)
	
	if is_instance_valid(enemy_hitbox) and is_instance_valid(enemy_hitbox.owner):
		var enemy := enemy_hitbox.owner as Node2D
		if enemy.has_meta(slow_meta_id):
			enemy.remove_meta(slow_meta_id)
			enemy.speed /= slow_factor

func _on_shoot_timer_timeout() -> void:
	if targets_in_range.is_empty():
		return
		
	shoot_aoe_pulse()

func shoot_aoe_pulse() -> void:
	print("DDoS Pulsar discharging massive packet traffic overflow burst!")
	
	is_pulsing = true
	pulse_progress = 0.0
	
	var verified_living_targets: Array[Area2D] = []
	
	for enemy_hitbox in targets_in_range:
		if is_instance_valid(enemy_hitbox) and enemy_hitbox.is_inside_tree():
			verified_living_targets.append(enemy_hitbox)
			
			var enemy := enemy_hitbox.owner as Node2D
			enemy.take_damage(damage)
			
	targets_in_range = verified_living_targets
