extends Node2D

@export var max_health: int = 2
@export var speed: float = 100
@export var reward_ram: int = 10
@export var damage_to_base: int = 1

var health: int
var last_global_position: Vector2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	animated_sprite.play("moving")
	last_global_position = global_position

func _process(delta: float) -> void:
	var parent := get_parent()
	
	if parent is PathFollow2D:
		parent.progress += speed * delta
		
		# Check if malware breached the end of the path
		if parent.progress_ratio >= 1.0:
			reach_end()
			return # Exit early since this node is being freed

	# 2. Handle Sprite Flipping (Preserved from your original script)
	var direction := global_position - last_global_position
	if abs(direction.x) > 0.1:
		if direction.x < 0:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false

	last_global_position = global_position

func take_damage(amount: int) -> void:
	health -= amount

	if health <= 0:
		die()

func die() -> void:
	GlobalGameState.add_ram(reward_ram)
	_safely_free()

func reach_end() -> void:
	GlobalGameState.take_base_damage(damage_to_base)
	_safely_free()

# Helper function to prevent empty PathFollow2D nodes from cluttering the hierarchy
func _safely_free() -> void:
	var parent := get_parent()
	if parent is PathFollow2D:
		parent.queue_free()
	else:
		queue_free()
