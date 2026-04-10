class_name Beacon extends Area2D

@onready var point_light: PointLight2D = $PointLight2D
@onready var light_range_area: Area2D = $LightRangeArea
@onready var progression_label: Label = $ProgressionLabel
@onready var raise_sfx: AudioStreamPlayer2D = $RaiseSFX
@onready var pitch_timer: Timer = $PitchTimer
@onready var unlock_sfx: AudioStreamPlayer2D = $UnlockSFX

@export var blockers: Array[Blocker]
@export var spawners: Array[CreatureSpawner]
@export var load_speed: float = 0.15
@export var unload_speed: float = -0.30
@export var level: int

var is_loading: bool = false
var progression: float = 0
var creatures_inside: int = 0
var unlocked: bool = false
var creatures_in_light: Array[CreatureGhoul] = []
var pitch_start: float = 1.0
var pitch_high: float = 2.0
var pitch_low: float = 0.5

func _ready() -> void:
	if GameManagerGlobal.has_beacon(level):
		enlight(true)

func _process(delta: float) -> void:
	var mod = 1.0
	if OS.has_feature("editor"):
		if Input.is_key_pressed(KEY_ALT):
			mod = 30.0
	
	if not unlocked:
		var speed = unload_speed if not is_loading else load_speed
		if creatures_inside <= 0:
			if speed > 0:
				raise_sfx.pitch_scale = lerpf(pitch_start, pitch_high, progression)
				if pitch_timer.is_stopped():
					if not raise_sfx.playing:
						raise_sfx.play()
					pitch_timer.start()
			elif speed < 0:
				raise_sfx.pitch_scale = pitch_low
				if pitch_timer.is_stopped():
					if not raise_sfx.playing:
						raise_sfx.play()
					pitch_timer.start()
			else:
				raise_sfx.stop()
				pitch_timer.stop()
			progression += delta * speed * mod
			progression = clampf(progression, 0.0, 1.0)
			progression_label.text = "%02.1f%%" % (progression * 100)
			if progression == 1.0:
				enlight()
		else:
			if not is_loading:
				speed = -1
				progression += delta * speed * mod
				progression = clampf(progression, 0.0, 1.0)
				progression_label.text = "%02.1f%%" % (progression * 100)
				raise_sfx.pitch_scale = pitch_low
				if pitch_timer.is_stopped():
					if not raise_sfx.playing:
						raise_sfx.play()
					pitch_timer.start()
			else:
				raise_sfx.stop()
				pitch_timer.stop()
			#print("Can't rise, creatures inside")
		if progression <= 0.0:
			raise_sfx.stop()
			pitch_timer.stop()

func enlight(again: bool = false) -> void:
	raise_sfx.stop()
	pitch_timer.stop()
	if not again:
		unlock_sfx.play()
		GameManagerGlobal.unlock_beacon(level, global_position)
	unlocked = true
	point_light.enabled = true
	progression_label.visible = false
	await get_tree().process_frame
	await get_tree().physics_frame
	for c in creatures_in_light:
		c.take_damage(1000)
	for b in blockers:
		b.remove_blocker()
	for s in spawners:
		s.destroy()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		is_loading = true
	elif body is CharacterBody2D:
		creatures_inside += 1

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		is_loading = false
	elif body is CharacterBody2D:
		creatures_inside -= 1

func _on_light_range_area_body_entered(body: Node2D) -> void:
	if body is CreatureGhoul:
		if unlocked:
			body.emit_signal("enter_light", light_range_area)
		else:
			creatures_in_light.append(body as CreatureGhoul)

func _on_light_range_area_body_exited(body: Node2D) -> void:
	if body is CreatureGhoul:
		creatures_in_light.erase(body as CreatureGhoul)
		if unlocked:
			body.emit_signal("exit_light", light_range_area)


func _on_pitch_timer_timeout() -> void:
	if not raise_sfx.playing:
		raise_sfx.play()
