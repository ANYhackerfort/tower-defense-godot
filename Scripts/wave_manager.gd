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
	print("========== WAVE MANAGER READY ==========")
	print("Total Waves: ", tutorial_waves.size())
	print("Total Paths: ", paths.size())

	for i in range(tutorial_waves.size()):
		var wave := tutorial_waves[i]
		if wave == null:
			print("Wave slot ", i, " is NULL")
		else:
			print("Wave slot ", i, ": ", wave.wave_name, " | spawns: ", wave.spawns.size())

	for i in range(paths.size()):
		print("Path slot ", i, ": ", paths[i])

	start_next_wave_countdown()

func start_next_wave_countdown() -> void:
	if current_wave_index >= tutorial_waves.size():
		return
		
	is_counting_down = true
	var time_left := time_between_waves
	
	print("Countdown starting for wave index ", current_wave_index)
	
	while time_left > 0 and is_counting_down:
		update_wave_display_countdown(time_left)
		
		var tree := get_tree()
		if tree == null:
			return
		
		await tree.create_timer(1.0, false).timeout
		
		if not is_inside_tree():
			return
		
		time_left -= 1.0
		
	is_counting_down = false
	start_wave()

func start_wave() -> void:
	if is_spawning_wave or active_enemies > 0:
		print("Cannot start wave yet. is_spawning_wave=", is_spawning_wave, " active_enemies=", active_enemies)
		return

	if current_wave_index >= tutorial_waves.size():
		print("No more waves to start.")
		return

	var wave := tutorial_waves[current_wave_index]
	if wave == null:
		push_error("Wave Manager: Current wave is null at index " + str(current_wave_index))
		return

	is_spawning_wave = true
	
	if wave_label:
		wave_label.text = wave.wave_name + "\nWave: " + str(current_wave_index + 1) + "/" + str(tutorial_waves.size())
	
	print("========== STARTING WAVE ==========")
	print("Wave index: ", current_wave_index)
	print("Wave name: ", wave.wave_name)
	print("Spawn groups: ", wave.spawns.size())

	active_spawn_routines = wave.spawns.size()

	if active_spawn_routines == 0:
		print("Wave has 0 spawn groups.")
		is_spawning_wave = false
		_try_complete_wave()
		return

	for spawn_index in range(wave.spawns.size()):
		var spawn_info := wave.spawns[spawn_index]
		process_spawn_info(spawn_info, spawn_index)
	
	while active_spawn_routines > 0:
		var tree := get_tree()
		if tree == null:
			return
		
		await tree.process_frame
		
		if not is_inside_tree():
			return
		
	is_spawning_wave = false
	print("All enemies for ", wave.wave_name, " have entered the system.")
	print("Active enemies after spawning finished: ", active_enemies)

	_try_complete_wave()

func process_spawn_info(spawn_info: EnemySpawnInfo, spawn_index: int) -> void:
	if spawn_info == null:
		push_error("Wave Manager: Spawn info is null at spawn index " + str(spawn_index))
		active_spawn_routines -= 1
		return

	if spawn_info.enemy_scene == null:
		push_error("Wave Manager: Enemy scene missing at spawn index " + str(spawn_index))
		active_spawn_routines -= 1
		return

	if spawn_info.path_index < 0 or spawn_info.path_index >= paths.size():
		push_error(
			"Wave Manager: Invalid path index " 
			+ str(spawn_info.path_index) 
			+ " at spawn index " 
			+ str(spawn_index) 
			+ ". Paths size is " 
			+ str(paths.size())
		)
		active_spawn_routines -= 1
		return

	var target_path := paths[spawn_info.path_index]

	if target_path == null:
		push_error("Wave Manager: Path is null at index " + str(spawn_info.path_index))
		active_spawn_routines -= 1
		return

	print("--- Spawn Group Started ---")
	print("Spawn index: ", spawn_index)
	print("Enemy scene: ", spawn_info.enemy_scene.resource_path)
	print("Count: ", spawn_info.count)
	print("Initial Delay: ", spawn_info.initial_delay)
	print("Spawn Delay: ", spawn_info.spawn_delay)
	print("Path Index: ", spawn_info.path_index)
	print("Path Node: ", target_path.name)

	if spawn_info.initial_delay > 0.0:
		var tree := get_tree()
		if tree == null:
			return
		
		await tree.create_timer(spawn_info.initial_delay, false).timeout
		
		if not is_inside_tree():
			return

	for i in range(spawn_info.count):
		var path_follow := PathFollow2D.new()
		path_follow.loop = false
		path_follow.rotates = false		
		
		var enemy_instance := spawn_info.enemy_scene.instantiate() as Node2D
		
		path_follow.add_child(enemy_instance)
		target_path.add_child(path_follow)
		
		active_enemies += 1

		print(
			"Spawned enemy #", i + 1,
			" from spawn group ", spawn_index,
			" | enemy=", spawn_info.enemy_scene.resource_path,
			" | path_index=", spawn_info.path_index,
			" | path=", target_path.name,
			" | active_enemies=", active_enemies
		)

		enemy_instance.tree_exited.connect(_on_enemy_destroyed)
		
		var tree := get_tree()
		if tree == null:
			return
		
		await tree.create_timer(spawn_info.spawn_delay, false).timeout
		
		if not is_inside_tree():
			return

	active_spawn_routines -= 1

	print("--- Spawn Group Finished ---")
	print("Spawn index: ", spawn_index)
	print("Remaining spawn routines: ", active_spawn_routines)
	print("Active enemies now: ", active_enemies)

func _on_enemy_destroyed() -> void:
	active_enemies -= 1
	
	if active_enemies < 0:
		active_enemies = 0
	
	print("Enemy removed. Active enemies left: ", active_enemies)
	
	_try_complete_wave()

func _try_complete_wave() -> void:
	print(
		"Checking wave completion | wave_index=", current_wave_index,
		" | active_enemies=", active_enemies,
		" | is_spawning_wave=", is_spawning_wave,
		" | active_spawn_routines=", active_spawn_routines
	)

	if current_wave_index >= tutorial_waves.size():
		print("Completion check stopped: current_wave_index >= tutorial_waves.size()")
		return

	if is_spawning_wave:
		print("Completion check stopped: still spawning wave.")
		return

	if active_spawn_routines > 0:
		print("Completion check stopped: spawn routines still running.")
		return

	if active_enemies > 0:
		print("Completion check stopped: enemies still alive.")
		return

	var completed_wave := tutorial_waves[current_wave_index]
	GlobalGameState.add_ram(completed_wave.reward_ram)
	
	print("========== WAVE CLEARED ==========")
	print("Cleared wave: ", completed_wave.wave_name)
	print("Reward RAM: ", completed_wave.reward_ram)
	
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
	
	var wave := tutorial_waves[current_wave_index]
	var display_wave: int = current_wave_index + 1
	var total_waves: int = tutorial_waves.size()
	
	wave_label.text = wave.wave_name + "\nWave " + str(display_wave) + "/" + str(total_waves) + " in " + str(int(ceil(time_left))) + "s"
