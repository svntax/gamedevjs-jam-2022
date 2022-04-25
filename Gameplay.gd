extends Node2D

onready var player = $Player
onready var score_label = $UILayer/Score

func _ready():
	player.connect("collected_ore", self, "update_score")

# Sets the text label to the current score in Globals
func update_score() -> void:
	score_label.set_text("Score: " + str(Globals.current_score))
