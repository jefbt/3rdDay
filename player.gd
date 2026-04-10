class_name Player extends CharacterBody2D

@export var speed = 180.0
@export var palm_light_cooldown: float = 1.0
@export var invincible_time: float = 0.3
@export var respawn_time: float = 3.0
@export var push_strength: float = 1500

@onready var palm_timer: Timer = $PalmTimer
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var respawn_timer: Timer = $RespawnTimer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_player_2: AudioStreamPlayer = $AudioStreamPlayer2
@onready var palm_light_sfx: AudioStreamPlayer = $PalmLightSFX
@onready var palm_light_error_sfx: AudioStreamPlayer = $PalmLightErrorSFX
@onready var collectible_sfx: AudioStreamPlayer2D = $CollectibleSFX
@onready var step_timer: Timer = $StepTimer
@onready var walk_sfx: AudioStreamPlayer2D = $WalkSFX

var can_palm_light: bool = true
var is_invincible: bool = false
var is_respawning: bool = false
var health: float = 5.0
var max_health: float = 5.0
var collectibles: int = 0
var god_mode: bool = false

func respawning() -> void:
	is_respawning = true
	print("You should be respawning")
	set_deferred("collision_shape.disabled", true)
	#collision_shape.disabled = true
	sprite.visible = false
	respawn_timer.start(respawn_time)

func respawn() -> void:
	health = max_health
	set_deferred("collision_shape.disabled", false)
	sprite.visible = true
	is_invincible = true
	invincible_timer.start(invincible_time)
	is_respawning = false
	var respawn_pos = GameManagerGlobal.get_respawn_position()
	var level = respawn_pos[0]
	GameManagerGlobal.teleport(level, respawn_pos[1])
	#collision_shape.disabled = false

func _physics_process(_delta: float) -> void:
	if OS.has_feature("editor"):
		if Input.is_key_pressed(KEY_SHIFT):
			collision_shape.disabled = true
		else:
			collision_shape.disabled = false
			
	if is_respawning:
		return
	
	if not GameManagerGlobal.is_game_started():
		return
		
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction * speed
		if step_timer.is_stopped():
			if not walk_sfx.playing:
				walk_sfx.play()
			step_timer.start()
	else:
		velocity = Vector2.ZERO
		step_timer.stop()
	move_and_slide()
	check_damage_collisions()
	
func take_damage(creature: CreatureGhoul, damage: float = 0) -> void:
	if is_invincible or health <= 0:
		return
	# TODO make blinking or other visual/sfx feedback
	is_invincible = true
	if creature:
		health -= creature.damage
		var direction = (global_position - creature.global_position).normalized()
		velocity = direction * push_strength
		move_and_slide()
		print("Player took " + str(creature.damage) + " damage from creature " + str(creature))
	else:
		health -= damage
		print("Player took " + str(damage) + " damage from hazzard")
	health = clamp(health, 0, max_health)
	invincible_timer.start(invincible_time)
	if health <= 0.0:
		walk_sfx.stop()
		step_timer.stop()
		audio_player_2.play()
		respawning()
	else:
		audio_player.play()
	
func check_damage_collisions() -> void:
	if is_invincible or is_respawning:
		return
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body is CreatureGhoul:
			take_damage(body)
			break
	
func _process(_delta: float) -> void:
	if is_respawning:
		return
		
	if not GameManagerGlobal.is_game_started():
		return
		
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("palm_light"):
		palm_light()

func palm_light() -> void:
	if can_palm_light:
		palm_light_sfx.play()
		can_palm_light = false
		palm_timer.start(palm_light_cooldown)
		var _pl: PalmLight = LightSpawnerGlobal.spawn_palm_light(position, rotation)
	else:
		if not palm_light_error_sfx.playing:
			palm_light_error_sfx.play()
	pass

func collect(_collectible: Collectible) -> void:
	GameManagerGlobal.collect()
	collectibles += 1
	collectible_sfx.play()
	#print("You got " + str(collectible))
	#print("You have " + str(collectibles) + " collectibles")

func _on_timer_timeout() -> void:
	can_palm_light = true

func _on_invincible_timer_timeout() -> void:
	is_invincible = false

func _on_respawn_timer_timeout() -> void:
	respawn()

func _on_step_timer_timeout() -> void:
	if not walk_sfx.playing:
		walk_sfx.play()
