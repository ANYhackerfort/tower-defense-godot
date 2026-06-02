extends Node2D

@export var enemy_scene: PackedScene
@export var enemy_speed: float = 100.0

@onready var path_follow_1: PathFollow2D = $Paths/Path1/PathFollow2D
@onready var path_follow_2: PathFollow2D = $Paths/Path2/PathFollow2D

var active_enemies: Array[PathFollow2D] = []

func _ready() -> void:
	spawn_enemy(path_follow_1)
	#spawn_enemy(path_follow_2)


func spawn_enemy(path_follow: PathFollow2D) -> void:
	path_follow.progress = 0.0
	var enemy := enemy_scene.instantiate()
	path_follow.add_child(enemy)
	active_enemies.append(path_follow)


func _process(delta: float) -> void:
	for path_follow in active_enemies.duplicate():
		path_follow.progress += enemy_speed * delta

		if path_follow.progress_ratio >= 1.0:
			path_follow.queue_free()
			active_enemies.erase(path_follow)
