extends Node2D

onready var player = $Player
onready var score_label = $UILayer/Score

func _ready():
	# Default size 1280x720
	OS.window_size = Vector2(1280, 720)
	# Center the window after resizing
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	
	player.connect("collected_ore", self, "update_score")

# Sets the text label to the current score in Globals
func update_score() -> void:
	score_label.set_text("Score: " + str(Globals.current_score))
