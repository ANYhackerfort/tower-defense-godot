extends CanvasLayer

func _ready() -> void:
	hide()
	GlobalGameState.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	show()
	get_tree().paused = true

func _on_restart_button_pressed() -> void:
	GlobalGameState.reset_game()

func _on_quit_pressed() -> void:
	get_tree().quit()	
