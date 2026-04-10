class_name Teleporter extends Area2D

@export var level: int
@export var pos: Vector2


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameManagerGlobal.teleport(level, pos)
