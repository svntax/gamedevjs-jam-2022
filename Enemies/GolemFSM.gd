extends "res://StateMachine.gd"

# States: IDLE, WALK, PUSHED
enum States {SLEEP, IDLE, WALK, HURT, DEAD}

func _ready():
	call_deferred("set_state", States.SLEEP)

func _state_logic(_delta):
	if state == States.WALK:
		actor.walk_towards_player()
	
func _state_transition(_delta):
	if state == States.IDLE:
		if not actor.player.is_alive():
			set_state(States.SLEEP)
		elif actor.check_player_in_range():
			set_state(States.WALK)
		else:
			set_state(States.SLEEP)
	elif state == States.WALK:
		if not actor.player.is_alive():
			set_state(States.SLEEP)

func _enter_state(new_state, old_state):
	match new_state:
		States.IDLE:
			if old_state == States.SLEEP:
				actor.animation_player.play("wake_up")
		States.SLEEP:
			actor.animation_player.play("sleep")
		States.HURT:
			actor.animation_player.play("hurt")
		States.WALK:
			actor.mine_timer.start()
		States.DEAD:
			actor.die()
