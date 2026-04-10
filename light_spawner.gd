class_name LightSpawner extends Node2D

const PALM_LIGHT = preload("res://palm_light.tscn")

func spawn_palm_light(_position: Vector2, _rotation: float) -> PalmLight:
	var palm_light: PalmLight = PALM_LIGHT.instantiate()
	if palm_light:
		palm_light.position = _position
		palm_light.rotation = _rotation
		add_child(palm_light)
		return palm_light
	else:
		return null
