# enemy_spawn_info.gd
extends Resource
class_name EnemySpawnInfo

@export var enemy_scene: PackedScene
@export var count: int = 5
@export var initial_delay: float = 0.0
@export var spawn_delay: float = 1.0   
@export var path_index: int = 0 
