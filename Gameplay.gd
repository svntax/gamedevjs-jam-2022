extends Node2D

onready var player = $Player
onready var cave = $Cave
onready var score_label = $UILayer/Score
onready var cave_music = $CaveMusic
onready var animation_player = $AnimationPlayer
onready var game_over_menu = $UILayer/GameOverMenu
onready var game_over_delay_timer = $GameOverDelay

func _ready():
	Globals.current_score = 0
	animation_player.play("RESET")
	cave_music.play()
	player.connect("collected_ore", self, "update_score")
	player.connect("died", self, "_on_player_death")
	cave.generate_cave()

# Sets the text label to the current score in Globals
func update_score() -> void:
	score_label.set_text("Score: " + str(Globals.current_score))

func _on_player_death():
	game_over_delay_timer.start()
	game_over_menu.set_score(Globals.current_score)

func _on_GameOverDelay_timeout():
	animation_player.play("game_over")
