class_name Collectible extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.collect(self)
		# TODO make fx/sfx to disappear
		queue_free()
