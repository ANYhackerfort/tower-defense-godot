extends CharacterBody2D

@export var speed: float = 160.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var input_dir: Vector2 = Vector2.ZERO
var last_dir: Vector2 = Vector2.DOWN
var is_placing: bool = false


func _physics_process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animation()

func handle_input() -> void:
	input_dir = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	if input_dir != Vector2.ZERO:
		last_dir = input_dir.normalized()

	# TODO: Dud for now, but ready later
	# Probably like an inventory system
	#if Input.is_action_just_pressed("place"):
		#is_placing = true

func handle_movement() -> void:
	velocity = input_dir * speed
	move_and_slide()

func handle_animation() -> void:
	# Override player movement
	if is_placing:
		play_directional_animation("place", last_dir)
		is_placing = false
		return

	if input_dir == Vector2.ZERO:
		play_directional_animation("idle", last_dir)
	else:
		play_directional_animation("walk", input_dir)


func play_directional_animation(prefix: String, dir: Vector2) -> void:
	var direction_name := get_direction_name(dir)
	var animation_name := ""

	match direction_name:
		"forward":
			animation_name = prefix + "_forward"
			anim.flip_h = false

		"backward":
			animation_name = prefix + "_backward"
			anim.flip_h = false

		"right":
			animation_name = prefix + "_right"
			anim.flip_h = false

		"left":
			animation_name = prefix + "_right"
			anim.flip_h = true

	if anim.animation != animation_name:
		anim.play(animation_name)

func get_direction_name(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			return "right"
		else:
			return "left"
	else:
		if dir.y < 0:
			return "forward"
		else:
			return "backward"
