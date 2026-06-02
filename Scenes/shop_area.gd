extends Area2D

@export var shop_ui: CanvasLayer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if shop_ui:
		shop_ui.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		shop_ui.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		shop_ui.visible = false
