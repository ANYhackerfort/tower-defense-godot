extends Node

@export var tutorial_waves: Array[WaveData] = []
@export var paths: Array[Path2D] = [] 
@export var wave_label: Label 
@export var time_between_waves: float = 30.0 

var current_wave_index: int = 0
var active_enemies: int = 0
var is_spawning_wave: bool = false
var active_spawn_routines: int = 0
var is_counting_down: bool = false

func _ready() -> void:
	print("Wave Manager Ready. Total Waves: ", tutorial_waves.size())
	start_next_wave_countdown()

func start_next_wave_countdown() -> void:
	if current_wave_index >= tutorial_waves.size():
		return
		
	is_counting_down = true
	var time_left := time_between_waves
	
	while time_left > 0 and is_counting_down:
		update_wave_display_countdown(time_left)
		
		var tree := get_tree()
		if tree == null: return
		
		await tree.create_timer(1.0, false).timeout
		
		if not is_inside_tree(): return
		
		time_left -= 1.0
		
	is_counting_down = false
	start_wave()

func start_wave() -> void:
	if is_spawning_wave or active_enemies > 0:
		return

	var wave := tutorial_waves[current_wave_index]
	is_spawning_wave = true
	
	if wave_label:
		wave_label.text = "Wave: " + str(current_wave_index + 1) + "/" + str(tutorial_waves.size())
	
	print("Starting: ", wave.wave_name)

	active_spawn_routines = wave.spawns.size()

	for spawn_info in wave.spawns:
		process_spawn_info(spawn_info)
	
	while active_spawn_routines > 0:
		var tree := get_tree()
		if tree == null: return
		
		await tree.process_frame
		
		if not is_inside_tree(): return
		
	is_spawning_wave = false
	print("All enemies for ", wave.wave_name, " have entered the system.")

func process_spawn_info(spawn_info: EnemySpawnInfo) -> void:
	if spawn_info.path_index >= paths.size():
		push_error("Wave Manager: Invalid path index assigned in resource data.")
		active_spawn_routines -= 1
		return

	var target_path := paths[spawn_info.path_index]

	for i in range(spawn_info.count):
		var path_follow := PathFollow2D.new()
		path_follow.loop = false
		path_follow.rotates = false		
		
		var enemy_instance := spawn_info.enemy_scene.instantiate() as Node2D
		
		path_follow.add_child(enemy_instance)
		target_path.add_child(path_follow)
		
		active_enemies += 1
		enemy_instance.tree_exited.connect(_on_enemy_destroyed)
		
		var tree := get_tree()
		if tree == null: return
		
		await tree.create_timer(spawn_info.spawn_delay, false).timeout
		
		if not is_inside_tree(): return

	active_spawn_routines -= 1

func _on_enemy_destroyed() -> void:
	active_enemies -= 1
	
	if active_enemies <= 0 and not is_spawning_wave:
		var completed_wave := tutorial_waves[current_wave_index]
		GlobalGameState.add_ram(completed_wave.reward_ram)
		
		print("System secure. ", completed_wave.wave_name, " cleared!")
		
		current_wave_index += 1
		
		if current_wave_index >= tutorial_waves.size():
			print("VICTORY! All malware purged from the level.")
			if wave_label:
				wave_label.text = "System Secure!"

			GlobalGameState.victory.emit()
		else:
			start_next_wave_countdown()

func update_wave_display_countdown(time_left: float) -> void:
	if wave_label == null:
		return
		
	var display_wave: int = current_wave_index + 1
	var total_waves: int = tutorial_waves.size()
	
	wave_label.text = "Wave " + str(display_wave) + "/" + str(total_waves) + " in " + str(int(ceil(time_left))) + "s"
