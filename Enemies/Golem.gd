extends KinematicBody2D

onready var body = $Body
onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer
onready var detect_area = $PlayerDetectArea

onready var player = null
onready var speed = 24

func _ready():
	player = get_tree().get_nodes_in_group("Players")[0]

func _on_PlayerDetectArea_body_entered(body):
	if body == player:
		if state_machine.state == state_machine.States.SLEEP:
			state_machine.set_state(state_machine.States.IDLE)

func _on_PlayerDetectArea_body_exited(body):
	if body == player:
		if state_machine.state == state_machine.States.WALK:
			state_machine.set_state(state_machine.States.IDLE)

func walk_towards_player() -> void:
	var dir = global_position.direction_to(player.global_position)
	var vel = dir * 32
	if vel.x >= 1:
		body.scale.x = 1
	elif vel.x <= -1:
		body.scale.x = -1
	move_and_slide(vel)
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var collider = collision.collider
		if collider.has_method("damage"):
			collider.damage()

func check_player_in_range() -> bool:
	return player in detect_area.get_overlapping_bodies()

func _on_PlayerCheck_timeout():
	if state_machine.state == state_machine.States.WALK:
		if not check_player_in_range():
			state_machine.set_state("IDLE")
