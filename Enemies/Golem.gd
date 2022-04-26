extends KinematicBody2D

#const GoldOre = preload("res://Ores/Gold.tscn")
#const IronOre = preload("res://Ores/Iron.tscn")
#const EmeraldOre = preload("res://Ores/Emerald.tscn")
const RubyOre = preload("res://Ores/Ruby.tscn")
#const SapphireOre = preload("res://Ores/Sapphire.tscn")

onready var body_root = $Body
onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer
onready var detect_area = $PlayerDetectArea
onready var damage_immunity_timer = $DamageImmunity

enum GolemType {RUBY}
onready var golem_type = GolemType.RUBY

onready var player = null
onready var speed = 24
onready var health = 3

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
		body_root.scale.x = 1
	elif vel.x <= -1:
		body_root.scale.x = -1
	move_and_slide(vel)
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var collider = collision.collider
		if collider.has_method("damage"):
			collider.damage()

func damage() -> void:
	if damage_immunity_timer.is_stopped():
		damage_immunity_timer.start()
		health -= 1
		if health == 0:
			drop_loot()
			queue_free()
		else:
			state_machine.set_state(state_machine.States.HURT)

func drop_loot() -> void:
	if golem_type == GolemType.RUBY:
		# Drop 2 ruby ores to the left and right
		var ore01 = RubyOre.instance()
		ore01.global_position = global_position + Vector2(randi() % 4 - 3, randi() % 5 - 2)
		get_parent().add_child(ore01)
		var ore02 = RubyOre.instance()
		ore02.global_position = global_position + Vector2(randi() % 4, randi() % 5 - 2)
		get_parent().add_child(ore02)
		if ore02.global_position.y == ore01.global_position.y:
			ore02.global_position.y += 1

func check_player_in_range() -> bool:
	return player in detect_area.get_overlapping_bodies()

func _on_PlayerCheck_timeout():
	if state_machine.state == state_machine.States.WALK:
		if not check_player_in_range():
			state_machine.set_state(state_machine.States.IDLE)

func _on_ImmunityTimer_timeout():
	if state_machine.state == state_machine.States.HURT:
		state_machine.set_state(state_machine.States.IDLE)
