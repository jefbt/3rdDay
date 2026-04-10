extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "Collectibles Found: " + str(GameManagerGlobal.collectibles) + "/9"
