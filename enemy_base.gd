extends Node2D

@export var max_health: int = 100
@export var speed: float = 80.0
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


func _process(_delta: float) -> void:
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
	queue_free()


func reach_end() -> void:
	GlobalGameState.take_base_damage(damage_to_base)
	queue_free()
