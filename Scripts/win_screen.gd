extends CanvasLayer

@export var next_level: PackedScene

func _ready() -> void:
	GlobalGameState.victory.connect(_on_victory)

func _on_victory() -> void:
	show()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_continue_button_pressed() -> void:
	GlobalGameState.next_level()
	get_tree().change_scene_to_packed(next_level)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
