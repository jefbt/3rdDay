class_name PalmLight extends Area2D

@onready var point_light: PointLight2D = $PointLight2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var fade_timer: Timer = $FadeTimer

@export var fade_time: float = 0.5

var starting_energy: float = 1
var starting_opacity: float = 1

func _ready() -> void:
	starting_energy = point_light.energy
	starting_opacity = sprite.modulate.a
	fade_timer.start(fade_time)

func _process(_delta: float) -> void:
	point_light.energy = lerpf(0, starting_energy, fade_timer.time_left / fade_time)
	sprite.modulate.a = lerpf(0, starting_opacity, fade_timer.time_left / fade_time)

func _on_fade_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CreatureGhoul:
		body.emit_signal("enter_light", self)
	


func _on_body_exited(body: Node2D) -> void:
	if body is CreatureGhoul:
		body.emit_signal("exit_light", self)
