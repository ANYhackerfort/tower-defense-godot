extends Node2D

var ghost_tower: Node2D = null
var can_place: bool = true

var placement_size := Vector2(128, 128)
var place_distance: float = 96.0
var waiting_for_mouse_release: bool = false

@export var no_build_zones_parent: Node2D

func _process(_delta: float) -> void:
	if GlobalGameState.selected_tower_scene == null:
		clear_ghost()
		return

	var player := get_player()
	if player == null:
		return

	if ghost_tower == null:
		create_ghost()
		waiting_for_mouse_release = true

	var place_pos := get_place_position(player)
	ghost_tower.global_position = place_pos

	can_place = check_can_place(place_pos)

	if ghost_tower.has_method("set_can_place"):
		ghost_tower.set_can_place(can_place)

	if waiting_for_mouse_release:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			waiting_for_mouse_release = false
		return

	if Input.is_action_just_pressed("left_click") and can_place:
		place_tower(place_pos)

func get_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null

	return players[0] as Node2D

func get_place_position(player: Node2D) -> Vector2:
	var dir: Vector2 = player.last_dir
	return player.global_position + dir.normalized() * place_distance

func create_ghost() -> void:
	ghost_tower = GlobalGameState.selected_tower_scene.instantiate()

	if ghost_tower.has_method("set_as_ghost"):
		ghost_tower.set_as_ghost(true)

	add_child(ghost_tower)

func check_can_place(pos: Vector2) -> bool:
	var ghost_rect := Rect2(
		pos - placement_size / 2.0,
		placement_size
	)
	
	# TODO: Maybe more efficient way to check if it overlaps with placed towers
	for tower in get_tree().get_nodes_in_group("placed_towers"):
		var tower_rect := Rect2(
			tower.global_position - placement_size / 2.0,
			placement_size
		)

		if ghost_rect.intersects(tower_rect):
			return false
	
	# TODO: More efficient call function below to check again with the same For Loop
	if overlaps_no_build_zone(ghost_rect):
		return false

	return true

# NOTE: Checks if it is overlapping with enemy path
func overlaps_no_build_zone(ghost_rect: Rect2) -> bool:
	if no_build_zones_parent == null:
		print("NoBuildZones parent not assigned")
		return false

	for zone in no_build_zones_parent.get_children():
		var shape_node := zone.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_node == null:
			continue

		var rect_shape := shape_node.shape as RectangleShape2D
		if rect_shape == null:
			continue

		var zone_size := rect_shape.size * shape_node.global_scale.abs()

		var zone_rect := Rect2(
			shape_node.global_position - zone_size / 2.0,
			zone_size
		)

		if ghost_rect.intersects(zone_rect):
			print("BLOCKED by:", zone.name)
			return true

	return false
	
func place_tower(pos: Vector2) -> void:
	var real_tower := GlobalGameState.selected_tower_scene.instantiate()
	real_tower.global_position = pos
	get_tree().current_scene.add_child(real_tower)

	GlobalGameState.selected_tower_scene = null
	GlobalGameState.selected_tower_cost = 0
	clear_ghost()

func clear_ghost() -> void:
	if ghost_tower != null:
		ghost_tower.queue_free()
		ghost_tower = null
