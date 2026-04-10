class_name CreatureGhoul extends CharacterBody2D

@export var is_ghost: bool = false
@export var health: float = 1.5
@export var speed: float = 50.0
@export var damage: float = 1.0
@export var follow_range: float = 120.0
@export var run_away_duration: float = 0.6

@onready var run_away_timer: Timer = $RunAwayTimer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var step: AudioStreamPlayer2D = $Step
@onready var step_timer: Timer = $StepTimer
@onready var run_away_player: AudioStreamPlayer2D = $RunAwayPlayer

signal enter_light(light)
signal exit_light(light)

var is_running_away: bool = false
var run_away_direction: Vector2 = Vector2.ZERO
var player: Player = null
var is_dead: bool = false

func _ready() -> void:
	if not player:
		player = get_tree().get_first_node_in_group("players")
	enter_light.connect(_on_enter_light)
	exit_light.connect(_on_exit_light)

func take_damage(_damage: float) -> void:
	if is_dead or is_ghost:
		return
	# TODO make blinking or other visual/sfx feedback
	health -= _damage
	if health <= 0:
		step_timer.stop()
		# TODO make a die function to show what happened
		audio.play()
		timer.start()
		is_dead = true
		sprite.visible = false
		shape.disabled = true
	pass

func _process(delta: float) -> void:
	if is_dead:
		return
	if is_running_away:
		velocity = run_away_direction * speed * 1.1
		move_and_slide()
		step_timer.stop()
	elif player and not player.is_respawning:
		var distance_array: Vector2 = player.global_position - global_position
		var sqr_range = follow_range * follow_range
		if distance_array.length_squared() <= sqr_range:
			follow_player(delta)
		else:
			step_timer.stop()
	else:
		step_timer.stop()
		velocity = Vector2.ZERO
		move_and_slide()

func follow_player(_delta: float) -> void:
	if is_dead:
		return
	if player:
		var direction_vector: Vector2 = player.global_position - global_position
		velocity = direction_vector.normalized() * speed
		move_and_slide()
		look_at(player.global_position)
		if step_timer.is_stopped():
			step_timer.start()
	else:
		step_timer.stop()

func _on_enter_light(light: Area2D) -> void:
	if is_dead:
		return
	if player:
		look_at(-player.global_position)
		run_away_direction = (global_position - player.global_position).normalized()
	else:
		look_at(-light.global_position)
		run_away_direction = (global_position - light.global_position).normalized()
	is_running_away = true
	run_away_player.play()
	pass

func _on_exit_light(_light) -> void:
	if is_dead:
		return
	if is_inside_tree() and self:
		run_away_timer.start(run_away_duration)

func _on_run_away_timer_timeout() -> void:
	if is_dead:
		return
	is_running_away = false


func _on_timer_timeout() -> void:
	queue_free()


func _on_step_timer_timeout() -> void:
	if not step.playing:
		step.play()
