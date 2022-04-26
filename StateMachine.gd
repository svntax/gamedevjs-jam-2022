extends Node

var state
var previous_state

onready var actor = get_parent()

func _physics_process(delta):
	if state != null:
		_state_logic(delta)
		_state_transition(delta)

func _state_logic(_delta):
	pass

func _state_transition(_delta):
	pass

func _enter_state(_new_state, _old_state):
	pass

func _exit_state(_old_state, _new_state):
	pass

func set_state(new_state):
	var old_state = state
	previous_state = state
	state = new_state
	if old_state != null:
		_exit_state(old_state, new_state)
	if new_state != null:
		_enter_state(new_state, old_state)
