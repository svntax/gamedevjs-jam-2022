extends Area2D

func hit() -> void:
	for body in get_overlapping_bodies():
		if body.has_method("damage"):
			body.damage()
