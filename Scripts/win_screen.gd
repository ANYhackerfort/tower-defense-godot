extends CanvasLayer

func _ready() -> void:
	hide() # Hide the win screen by default when the map loads
	GlobalGameState.victory.connect(_on_victory)

func _on_victory() -> void:
	show()

func _on_quit_pressed() -> void:
	get_tree().quit()
