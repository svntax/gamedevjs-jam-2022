extends Control

onready var score_label = $ScoreLabel

func _on_NextButton_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")

func set_score(value: int) -> void:
	score_label.set_text("Score: " + str(value))
