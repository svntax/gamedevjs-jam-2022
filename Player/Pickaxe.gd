extends Area2D

onready var sprite = $PickaxeSprite
onready var animation_player = $AnimationPlayer

func hit() -> void:
	animation_player.play("mine")
	for body in get_overlapping_bodies():
		if body.is_in_group("Players"):
			continue
		if body.has_method("damage"):
			body.damage()

func face_right() -> void:
	sprite.flip_h = false

func face_left() -> void:
	sprite.flip_h = true
