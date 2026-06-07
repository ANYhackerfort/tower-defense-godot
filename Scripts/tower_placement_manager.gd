extends Node2D

@export var player: Node2D
@export var no_build_zones_parent: Node2D

var ghost_tower: Node2D = null
var can_place: bool = true

var placement_size := Vector2(128, 128)
var place_distance: float = 96.0

func _process(_delta: float) -> void:
	if GlobalGameState.selected_tower_scene == null:
		clear_ghost()
		if Input.is_action_just_pressed("place"):
			handle_tower_pickup()
		return
	
	if ghost_tower == null:
		create_ghost()

	var place_pos := get_place_position()
	ghost_tower.global_position = place_pos

	can_place = check_can_place(place_pos)

	if ghost_tower.has_method("set_can_place"):
		ghost_tower.set_can_place(can_place)

	if Input.is_action_just_pressed("place") and can_place:
		place_tower(place_pos)

func get_place_position() -> Vector2:
	var dir: Vector2 = player.last_dir
	return player.global_position + dir.normalized() * place_distance

func create_ghost() -> void:
	ghost_tower = GlobalGameState.selected_tower_scene.instantiate()
	
	if "is_ghost" in ghost_tower:
		ghost_tower.is_ghost = true
	
	add_child(ghost_tower)

func handle_tower_pickup() -> void:
	var pickup_nodes := get_tree().get_nodes_in_group("player_can_pickup")
	if pickup_nodes.is_empty():
		return
	
	var closest_tower: Node2D = null
	var min_dist: float = INF
	
	for tower in pickup_nodes:
		var dist := global_position.distance_to(tower.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_tower = tower as Node2D
			
	if closest_tower == null:
		return

	GlobalGameState.selected_tower_scene = closest_tower.source_scene	
	closest_tower.remove_from_group("placed_towers")
	closest_tower.remove_from_group("player_can_pickup")
	
	closest_tower.queue_free()
	print("Picked up tower: ", closest_tower.name)

func check_can_place(pos: Vector2) -> bool:
	var ghost_rect := Rect2(
		pos - placement_size / 2.0,
		placement_size
	)
	
	for tower in get_tree().get_nodes_in_group("placed_towers"):
		var tower_rect := Rect2(
			tower.global_position - placement_size / 2.0,
			placement_size
		)

		if ghost_rect.intersects(tower_rect):
			return false
	
	if overlaps_no_build_zone(ghost_rect):
		return false

	return true

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
			return true

	return false
	
func place_tower(pos: Vector2) -> void:
	var real_tower = GlobalGameState.selected_tower_scene.instantiate()
	real_tower.global_position = pos
	get_tree().current_scene.add_child(real_tower)

	GlobalGameState.selected_tower_scene = null
	GlobalGameState.selected_tower_cost = 0
	clear_ghost()

func clear_ghost() -> void:
	if ghost_tower != null:
		ghost_tower.queue_free()
		ghost_tower = null
