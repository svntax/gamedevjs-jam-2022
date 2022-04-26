extends Node2D

var config = {
	"network_id": "testnet",
	"node_url": "https://rpc.testnet.near.org",
	"wallet_url": "https://wallet.testnet.near.org",
}
var wallet_connection

onready var menu = $Menu
onready var play_button = $Menu/PlayButton
onready var login_button = $LoginButton

func _ready():
	# Default size 1280x720
	OS.window_size = Vector2(1280, 720)
	# Center the window after resizing
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	
	Globals.current_score = 0
	Globals.challenge_mode = false
	play_button.grab_focus()
	
	# NEAR setup
	if Near.near_connection == null:
		Near.start_connection(config)
	
	wallet_connection = WalletConnection.new(Near.near_connection)
	wallet_connection.connect("user_signed_in", self, "_on_user_signed_in")
	wallet_connection.connect("user_signed_out", self, "_on_user_signed_out")
	if wallet_connection.is_signed_in():
		_on_user_signed_in(wallet_connection)

func _on_user_signed_in(_wallet: WalletConnection):
	login_button.set_text("Sign Out")

func _on_user_signed_out(_wallet: WalletConnection):
	login_button.set_text("Sign In")

func _on_PlayButton_pressed():
	get_tree().change_scene("res://Gameplay.tscn")

func _on_ChallengeButton_pressed():
	get_tree().change_scene("res://ChallengeScreen.tscn")

func _on_LeaderboardsButton_pressed():
	get_tree().change_scene("res://LeaderboardScreen.tscn")

func _on_LoginButton_pressed():
	if wallet_connection.is_signed_in():
		wallet_connection.sign_out()
	else:
		wallet_connection.sign_in(Globals.CONTRACT_NAME)
