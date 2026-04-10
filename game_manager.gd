class_name GameManager extends Node

@export var levels: Array[String]

@onready var music_player: AudioStreamPlayer = $MusicPlayer

var unloacked_beacons: Array[int] = []
var last_beacon: int = -1
var last_beacon_position: Vector2 = Vector2.ZERO
var game_state: int = 0

var collectibles: int = 0

var player: Player
var target_player_position: Vector2 = Vector2.ZERO

func restart_game() -> void:
	player = null
	collectibles = 0
	game_state = 0
	last_beacon = -1
	unloacked_beacons = []
	last_beacon_position = Vector2.ZERO
	target_player_position = Vector2.ZERO
	teleport(0,Vector2.ZERO)
	
func collect() -> void:
	collectibles += 1
	pass

func teleport(level: int, pos: Vector2) -> void:
	load(levels[level])
	await get_tree().physics_frame 
	get_tree().change_scene_to_file(levels[level])
	target_player_position = pos
	player = null

func _process(_delta: float) -> void:
	if game_state == 0 and get_tree().current_scene and get_tree().current_scene.name != "Main":
		start_game()
	if not player:
		player = get_tree().get_first_node_in_group("players")
		if player:
			var cam = player.find_child("Camera2D") as Camera2D
			if cam:
				cam.position_smoothing_enabled = false
			player.global_position = target_player_position
			await get_tree().process_frame
			if cam:
				cam.position_smoothing_enabled = true

func has_beacon(beacon: int)	 -> bool:
	return unloacked_beacons.has(beacon)

func is_game_started() -> bool:
	return game_state > 0

func start_game() -> void:
	game_state = 1
	if not music_player.playing:
		music_player.play()

func unlock_beacon(beacon: int, pos: Vector2) -> void:
	unloacked_beacons.append(beacon)
	last_beacon = beacon
	last_beacon_position = pos

func get_respawn_position() -> Array:
	if last_beacon >= 0:
		return [last_beacon, last_beacon_position]
	return [0, Vector2.ZERO]
