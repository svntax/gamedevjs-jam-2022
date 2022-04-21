extends KinematicBody2D
class_name Player

onready var speed = 56
onready var direction = 1 # 1 = right, -1 = left

func _physics_process(delta):
	var velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed
	move_and_slide(velocity)
