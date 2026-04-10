class_name Blocker extends StaticBody2D

func remove_blocker() -> void:
	print("Removing blocker")
	queue_free()
	# TODO make remove fx
