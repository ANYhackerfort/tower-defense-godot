extends Node2D

@export var starting_ram: int = 100
@export var starting_data: int = 10

@onready var background_music: AudioStreamPlayer = $BackgroundMusic

func _ready() -> void:
	GlobalGameState.setup_level(starting_ram, starting_data)
	background_music.play()
