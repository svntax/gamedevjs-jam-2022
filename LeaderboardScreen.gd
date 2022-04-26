extends Node2D

onready var scores_grid = $Control/ScrollContainer/ScoresGrid
onready var player_name_label = $Control/ScrollContainer/ScoresGrid/PlayerName
onready var player_score_label = $Control/ScrollContainer/ScoresGrid/PlayerScore
onready var message_label = $Control/MessageLabel

func _ready():
	# First, hide the placeholder labels
	player_name_label.hide()
	player_score_label.hide()
	
	# Next, fetch the high scores and create new labels for each score
	var result = Near.call_view_method(Globals.CONTRACT_NAME, "get_scores")
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
	if result.has("error"):
		message_label.set_text("Error: Failed to get high scores")
		message_label.show()
	else:
		message_label.hide()
		var data = result.data
		var json_data = JSON.parse(data)
		var high_scores: Array = json_data.result
		
		if high_scores.empty():
			message_label.set_text("No high scores submitted yet.")
			message_label.show()
		
		# Selection sort
		for i in high_scores.size() - 1:
			var indexOfLargest = i
			for j in range(i+1, high_scores.size()):
				if high_scores[j][1] > high_scores[indexOfLargest][1]:
					indexOfLargest = j
			if indexOfLargest != i:
				# Swap
				var temp = high_scores[i]
				high_scores[i] = high_scores[indexOfLargest]
				high_scores[indexOfLargest] = temp
		
		for score in high_scores:
			var name_label = player_name_label.duplicate()
			name_label.set_text(str(score[0]))
			scores_grid.add_child(name_label)
			name_label.show()
			
			var score_label = player_score_label.duplicate()
			score_label.set_text(str(score[1]))
			scores_grid.add_child(score_label)
			score_label.show()

func _on_BackButton_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")
