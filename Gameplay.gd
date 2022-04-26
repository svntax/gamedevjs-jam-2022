extends Node2D

onready var player = $Player
onready var camera = $Player/Camera2D
onready var cave = $Cave
onready var score_label = $UILayer/Score
onready var cave_music = $CaveMusic
onready var animation_player = $AnimationPlayer
onready var game_over_menu = $UILayer/GameOverMenu
onready var game_over_delay_timer = $GameOverDelay

var wallet_connection

func _ready():
	Globals.current_score = 0
	animation_player.play("RESET")
	cave_music.play()
	player.connect("collected_ore", self, "update_score")
	player.connect("died", self, "_on_player_death")
	cave.generate_cave()
	camera.limit_right = cave.cave_width * 16
	
	wallet_connection = WalletConnection.new(Near.near_connection)
	if wallet_connection.is_signed_in():
		# Check for golden pickaxe ownership
		var nft_contract = "svntaxalt.testnet"
		var args = {"account_id": wallet_connection.get_account_id()}
		var result = Near.call_view_method(nft_contract, "nft_tokens_for_owner", args)
		if result is GDScriptFunctionState:
			result = yield(result, "completed")
		if result.has("error"):
			print("Error when fetching user's NFT's")
		else:
			var data = result.data
			var json_data = JSON.parse(data)
			var nft_list: Array = json_data.result
			if nft_list.empty():
				print("No NFT's found")
			for nft in nft_list:
				if nft["token_id"].begins_with("10:"):
					var id_array = nft["token_id"].split(":")
					if id_array.size() == 2:
						var edition = int(id_array[1])
						if 1 <= edition and edition <= 10:
							player.equip_golden_pickaxe()
							break

# Sets the text label to the current score in Globals
func update_score() -> void:
	score_label.set_text("Score: " + str(Globals.current_score))

func _on_player_death():
	game_over_delay_timer.start()
	game_over_menu.set_score(Globals.current_score)
	if Globals.challenge_mode and wallet_connection.is_signed_in():
		var args = {"new_score": Globals.current_score}
		wallet_connection.call_change_method(Globals.CONTRACT_NAME, "submit_score", args)

func _on_GameOverDelay_timeout():
	animation_player.play("game_over")

func _on_Exit_body_entered(body):
	if body.has_method("leave"):
		body.leave()
		Globals.current_score *= 2
		update_score()
		_on_player_death()
