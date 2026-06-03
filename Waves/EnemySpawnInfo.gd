# enemy_spawn_info.gd
class_name EnemySpawnInfo
extends Resource

@export var enemy_scene: PackedScene
@export var count: int = 5
@export var spawn_delay: float = 1.0
@export var path_index: int = 0 # 0 for Path A, 1 for Path B
