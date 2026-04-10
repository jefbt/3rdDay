class_name CreatureSpawner extends Node2D

var creature_type = preload("res://creature_ghoul.tscn")

@export var max_spawned: int = 1
@export var spawn_delay: float = 5

@onready var spawn_timer: Timer = $SpawnTimer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func spawn() -> void:
	var count := 0
	for c in get_children():
		if c is CharacterBody2D:
			count += 1
	if count < max_spawned:
		audio_stream_player_2d.play()
		var creature = creature_type.instantiate() as CharacterBody2D
		add_child(creature)
		creature.position = Vector2.ZERO
		creature.rotate(randf() * 2 * PI)
		creature.move_and_slide()

func _on_spawn_timer_timeout() -> void:
	spawn()
	
func destroy() -> void:
	queue_free()
	pass
