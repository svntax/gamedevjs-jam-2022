extends KinematicBody2D
class_name Golem

#const GoldOre = preload("res://Ores/Gold.tscn")
#const IronOre = preload("res://Ores/Iron.tscn")
const EmeraldOre = preload("res://Ores/Emerald.tscn")
const RubyOre = preload("res://Ores/Ruby.tscn")
const SapphireOre = preload("res://Ores/Sapphire.tscn")

signal mine(target_pos)

onready var body_root = $Body
onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer
onready var detect_area = $PlayerDetectArea
onready var damage_immunity_timer = $DamageImmunity
onready var mine_timer = $MineTimer
onready var costume_player = $CostumePlayer
onready var hurt_sound = $HurtSound

onready var golem_type = Globals.OreType.RUBY

onready var player = null
onready var speed = 26
onready var health = 3
onready var velocity = Vector2()

func _ready():
	player = get_tree().get_nodes_in_group("Players")[0]
	if randf() < 0.5:
		body_root.scale.x = -1

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
	velocity = dir * speed
	if velocity.x >= 1:
		body_root.scale.x = 1
	elif velocity.x <= -1:
		body_root.scale.x = -1
	move_and_slide(velocity)
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var collider = collision.collider
		if collider.has_method("damage"):
			collider.damage()

func damage() -> void:
	if damage_immunity_timer.is_stopped():
		damage_immunity_timer.start()
		health -= 1
		hurt_sound.play()
		if health == 0:
			drop_loot()
			state_machine.set_state(state_machine.States.DEAD)
		else:
			state_machine.set_state(state_machine.States.HURT)

func die() -> void:
	hide()
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)

func set_ore_type(ore_type: int) -> void:
	golem_type = ore_type
	if golem_type == Globals.OreType.RUBY:
		costume_player.play("ruby")
		health = 3
	elif golem_type == Globals.OreType.SAPPHIRE:
		costume_player.play("sapphire")
		health = 6

func drop_loot() -> void:
	if golem_type == Globals.OreType.RUBY:
		# Drop 2 ruby ores to the left and right
		var ore01 = RubyOre.instance()
		ore01.global_position = global_position + Vector2(randi() % 4 - 3, randi() % 5 - 2)
		get_parent().add_child(ore01)
		var ore02 = RubyOre.instance()
		ore02.global_position = global_position + Vector2(randi() % 4, randi() % 5 - 2)
		get_parent().add_child(ore02)
		if ore02.global_position.y == ore01.global_position.y:
			ore02.global_position.y += 1
	elif golem_type == Globals.OreType.SAPPHIRE:
		# Drop 1 sapphire ore and emerald ore
		var ore01 = SapphireOre.instance()
		ore01.global_position = global_position
		get_parent().add_child(ore01)
		var ore02 = EmeraldOre.instance()
		ore02.global_position = ore01.global_position + Vector2(randi() % 4 - 3, randi() % 5 - 2)
		get_parent().add_child(ore02)

func check_player_in_range() -> bool:
	return player in detect_area.get_overlapping_bodies()

func _on_PlayerCheck_timeout():
	if state_machine.state == state_machine.States.WALK:
		if not check_player_in_range():
			state_machine.set_state(state_machine.States.IDLE)

func _on_ImmunityTimer_timeout():
	if state_machine.state == state_machine.States.HURT:
		state_machine.set_state(state_machine.States.IDLE)

func _on_MineTimer_timeout():
	if state_machine.state == state_machine.States.WALK:
		mine_timer.start()
		mine()

func mine() -> void:
	var mine_dir = Vector2()
	if abs(velocity.x) > abs(velocity.y):
		mine_dir.x = velocity.x
	else:
		mine_dir.y = velocity.y
	var mine_pos = global_position + mine_dir.normalized() * 16
	emit_signal("mine", mine_pos, self)

func _on_HurtSound_finished():
	if health <= 0:
		queue_free()
