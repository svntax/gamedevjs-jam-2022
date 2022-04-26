extends Node2D

onready var message_label = $Control/MessageLabel
onready var start_button = $Control/StartButton
onready var seed_label = $Control/SeedLabel

var wallet_connection

func _ready():
	start_button.hide()
	seed_label.hide()
	wallet_connection = WalletConnection.new(Near.near_connection)
	if wallet_connection.is_signed_in():
		var result = Near.call_view_method(Globals.CONTRACT_NAME, "get_level_seed")
		if result is GDScriptFunctionState:
			result = yield(result, "completed")
		if result.has("error"):
			message_label.set_text("Error: Failed to get the level seed.")
			message_label.show()
		else:
			var data = result.data
			var json_data = JSON.parse(data)
			Globals.challenge_mode_seed = json_data.result
			start_button.show()
			seed_label.set_text("Today's seed: " + str(Globals.challenge_mode_seed))
			seed_label.show()
			message_label.set_text("Try to get the best score!")
	else:
		message_label.set_text("You must be signed in\nto play challenge mode.")

func _on_BackButton_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")

func _on_StartButton_pressed():
	Globals.challenge_mode = true
	get_tree().change_scene("res://Gameplay.tscn")
