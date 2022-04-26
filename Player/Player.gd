extends KinematicBody2D
class_name Player

signal mine(target_pos, source)
signal collected_ore()
signal died()

const BASE_SPEED = 56
onready var speed = 56
onready var x_direction = 1 # 1 = right, -1 = left
onready var y_direction = 0 # 1 = down, -1 = up
onready var direction = Vector2(x_direction, y_direction)
onready var alive = true
# Debug vars
onready var original_collision_layer = collision_layer
onready var original_collision_mask = collision_mask

onready var pickaxe = $Pickaxe
onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var move_cooldown_timer = $MoveCooldownTimer
onready var collect_sound = $CollectSound
onready var death_sound = $DeadSound

func _ready():
	pickaxe.hide()

func _physics_process(_delta):
	var velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed
	x_direction = sign(velocity.x)
	if x_direction == 1:
		sprite.scale.x = 1
	elif x_direction == -1:
		sprite.scale.x = -1
	y_direction = sign(velocity.y)
	if x_direction != 0 or y_direction != 0:
		direction.x = x_direction
		direction.y = y_direction
		if x_direction != 0 and y_direction != 0:
			direction.y = 0
	if _can_move():
		move_and_slide(velocity)
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			var collider = collision.collider
			if collider is Golem:
				self.damage()

func _can_move() -> bool:
	if not move_cooldown_timer.is_stopped():
		return false
	return is_alive()

func _can_mine() -> bool:
	if animation_player.is_playing() and animation_player.current_animation == "mine":
		return false
	return is_alive()

func _process(_delta):
	if Input.is_action_just_pressed("main_action"):
		if _can_mine():
			var mine_pos = global_position + direction * 12
			pickaxe.global_position = mine_pos
			animation_player.stop()
			animation_player.play("mine")
			move_cooldown_timer.start()
			if sprite.scale.x == 1:
				pickaxe.face_right()
			elif sprite.scale.x == -1:
				pickaxe.face_left()
			pickaxe.hit()
			emit_signal("mine", mine_pos, self)
	# TODO: debug, remove later
#	if Input.is_action_just_pressed("debug_toggle") and not Globals.challenge_mode:
#		if collision_layer == 0:
#			collision_layer = original_collision_layer
#			collision_mask = original_collision_mask
#			speed = BASE_SPEED
#		else:
#			collision_layer = 0
#			collision_mask = 0
#			speed = 200

func _on_MoveCooldown_timeout():
	# Unused for now
	pass

func equip_golden_pickaxe() -> void:
	pickaxe.turn_into_golden()

func damage() -> void:
	if alive:
		alive = false
		set_deferred("collision_layer", 0)
		hide()
		death_sound.play()
		emit_signal("died")

func leave() -> void:
	alive = false
	set_deferred("collision_layer", 0)
	hide()

func is_alive() -> bool:
	return alive

func collect(ore) -> void:
	if ore.ore_type == Globals.OreType.GOLD:
		Globals.current_score += 10
	elif ore.ore_type == Globals.OreType.IRON:
		Globals.current_score += 50 # TODO: Should iron give score? Repair pickaxe?
	elif ore.ore_type == Globals.OreType.EMERALD:
		Globals.current_score += 100
	elif ore.ore_type == Globals.OreType.RUBY:
		Globals.current_score += 250
	elif ore.ore_type == Globals.OreType.SAPPHIRE:
		Globals.current_score += 1000
	collect_sound.play()
	emit_signal("collected_ore")
