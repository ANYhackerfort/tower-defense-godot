extends Node2D

@export var speed: float = 500.0

var damage: int = 1
var target: Node2D = null

func _process(delta: float) -> void:
	if not is_instance_valid(target) or not target.is_inside_tree():
		queue_free()
		return

	var direction := (target.global_position - global_position).normalized()
	global_position += direction * speed * delta

	rotation = direction.angle()

	if global_position.distance_to(target.global_position) < 5.0:
		_on_hit()

func _on_hit() -> void:
	target.take_damage(damage)
	queue_free()
