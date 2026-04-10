class_name Spike extends Area2D

@export var damage: float = 1.5

func _on_body_entered(body: Node2D) -> void:
	if body is CreatureGhoul:
		body.take_damage(damage)
	elif body is Player:
		body.take_damage(null, damage)


func _on_body_exited(_body: Node2D) -> void:
	pass # Replace with function body.
