extends SubViewportContainer

@export var wait_time: float = 2
@onready var label_2: Label = $SubViewport/Control/ColorRect/Label2

func _ready() -> void:
	visible = true
	wait_time = Time.get_ticks_msec() + wait_time * 1000
	label_2.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameManagerGlobal.is_game_started():
		queue_free()
		return
		
	if Time.get_ticks_msec() < wait_time:
		return
	else:
		label_2.visible = true
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_key_pressed(KEY_SPACE):
		GameManagerGlobal.start_game()
		pass
