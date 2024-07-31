extends Node
## The main class that starts when the game runs.
## It's responsible for scene transitions.
## It's also responsible for making data persist across scenes.
## [br][br]
## This is one of those classes that are a bit ugly.
## Many things found in this class are probably not supposed to be here.


## The default file path for the game's save file.
## In the future, this should be in some
## user settings class, but such class does not exist yet.
const SAVE_FILE_PATH: String = "user://gamesave.json"

## The scene to jump to when entering the main menu.
@export var main_menu_scene: PackedScene
## The scene to jump to when entering a game.
## We also need this scene whenever we want to create or load a game.
@export var game_scene: PackedScene

## Setting this automatically removes the previous scene
## from the scene tree and adds the new scene to the scene tree.
var current_scene: Node:
	set(value):
		if current_scene:
			remove_child(current_scene)
			current_scene.queue_free()
		current_scene = value
		add_child(current_scene)

# Things that need to persist between scenes
@onready var players := $Players as Players
@onready var chat := $Chat as Chat

## This is to make sure that in online games,
## everything is properly synchronized before starting the game.
@onready var sync_check: SyncCheck


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_connected.connect(_on_multiplayer_peer_connected)
	players.player_added.connect(_on_player_added)
	
	chat.send_global_message("Type /help to get a list of commands.")
	
	# Enter the main menu when the game starts running
	_on_main_menu_entered()


## Tries to load a game at the default save file path.
## If it fails, sends a system message in the chat.
## If it succeeds, sends a global message in the chat
## and loads the new game scene.
func load_game() -> void:
	var game_from_path := GameFromPath.new()
	game_from_path.load_game(SAVE_FILE_PATH, game_scene)
	
	if game_from_path.error:
		chat.send_system_message("Failed to load the game")
		print_debug(game_from_path.error_message)
		return
	
	chat.send_global_message("[color=#60ff60]Game loaded[/color]")
	play_game(game_from_path.result)


## Loads the test map and loads the new resulting game scene.
## @deprecated
func load_game_from_scenario(scenario: Scenario1, rules: GameRules) -> void:
	var game_from_scenario := GameFromScenario.new()
	game_from_scenario.load_game(scenario, rules, game_scene)
	
	if game_from_scenario.error:
		print_debug(game_from_scenario.error_message)
		return
	
	play_game(game_from_scenario.result)


## Takes a Game instance, connects its signals, injects some dependencies
## into it, sets it as the current scene and starts the game loop.
## If playing online multiplayer, this is where the game is sent to clients.
func play_game(game: Game) -> void:
	# bad code
	game._turn_order_list.new_human_player_requested.connect(
			_on_game_new_player_requested
	)
	
	game.game_started.connect(_on_game_started)
	game.game_ended.connect(_on_main_menu_entered)
	game.chat = chat
	game.setup_players(players)
	_send_game_to_clients(game)
	current_scene = game
	game.start()


#region Inform clients that a game started
## The server calls this to inform clients that a game started.
## This function has no effect if you're not connected as a server.
## You may provide a multiplayer id to send the data to one specific client.
func _send_game_to_clients(game: Game, multiplayer_id: int = -1) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	
	var game_to_json := GameToJSON.new()
	game_to_json.convert_game(game)
	if game_to_json.error:
		print_debug(
				"Error converting game to JSON: "
				+ game_to_json.error_message
		)
		return
	
	if multiplayer_id == -1:
		_receive_new_game.rpc(game_to_json.result)
	else:
		_receive_new_game.rpc_id(multiplayer_id, game_to_json.result)


## The client receives a new game from the server.
## The game is built from the given JSON data, then we wait
## until we've received everything else before we start the game.
@rpc("authority", "call_remote", "reliable")
func _receive_new_game(game_json: Dictionary) -> void:
	var game_from_json := GameFromJSON.new()
	game_from_json.load_game(game_json, game_scene)
	
	if game_from_json.error:
		print_debug(game_from_json.error_message)
		return
	
	if not sync_check.is_sync_finished():
		await sync_check.sync_finished
	play_game(game_from_json.result)
#endregion


#region Inform clients that we enter the main menu
## The server calls this to inform clients that the main menu is entered.
## This function has no effect if you're not connected as a server.
## You may provide a multiplayer id to send the info to one specific client.
func _send_enter_main_menu_to_clients(multiplayer_id: int = -1) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	
	if multiplayer_id == -1:
		_receive_enter_main_menu.rpc()
	else:
		_receive_enter_main_menu.rpc_id(multiplayer_id)


## The client receives the info that we've entered the main menu.
@rpc("authority", "call_remote", "reliable")
func _receive_enter_main_menu() -> void:
	_on_main_menu_entered()
#endregion


#region Send new player to clients
# TODO This code shouldn't be in the main class, really.
## The server sends information about a new player to clients,
## namely the Player's id and its associated GamePlayer's id.
func _send_new_player_to_clients(player_id: int, game_player_id: int) -> void:
	_receive_new_player.rpc(player_id, game_player_id)


## The client receives the server's info about a new player.
## Once the player's data is done synchronizing, the player
## is assigned to the correct GamePlayer.
@rpc("authority", "call_remote", "reliable")
func _receive_new_player(player_id: int, game_player_id: int) -> void:
	var player: Player = players.add_received_player(str(player_id))
	await player.sync_finished
	
	if not current_scene is Game:
		return
	(current_scene as Game).game_players.assign_player(
			player, game_player_id
	)
#endregion


# This is very ugly code
## Adds a new player with given game player id.
## This is for creating a new [Player] that
## will be assigned to a specific [GamePlayer].
@rpc("any_peer", "call_remote", "reliable")
func _add_new_player(game_player_id: int) -> void:
	var multiplayer_id: int = multiplayer.get_remote_sender_id()
	if multiplayer_id == 0:
		multiplayer_id = 1
	
	# horrible
	var game_player: GamePlayer = (
			(current_scene as Game).game_players.player_from_id(game_player_id)
	)
	
	# DANGER this relies on the fact that new_unique_id will
	# return the same thing when Players adds the new player
	game_player.player_human_id = players.new_unique_id()
	var data := {
		"is_human": true,
		"custom_username": game_player.username,
	}
	players._add_remote_player(multiplayer_id, data)


func _on_connected_to_server() -> void:
	sync_check = SyncCheck.new([players])


func _on_multiplayer_peer_connected(multiplayer_id: int) -> void:
	if not multiplayer.is_server():
		return
	
	# Make sure that the client receives the
	# updated list that contains the client's players
	players.get_client_data(multiplayer_id)
	await players.player_group_added
	players.send_all_data(multiplayer_id)
	
	if current_scene is Game:
		_send_game_to_clients(current_scene as Game, multiplayer_id)
	elif current_scene is MainMenu:
		_send_enter_main_menu_to_clients(multiplayer_id)
	else:
		print_debug("Unrecognized scene. Cannot sync scene with new client.")


func _on_player_added(player: Player) -> void:
	var game := current_scene as Game
	if not game:
		players._send_new_player_to_clients(player)
		return
	
	if not MultiplayerUtils.has_authority(multiplayer):
		return
	
	var game_player_id: int = game.game_players.assign_player(player)
	
	if MultiplayerUtils.is_server(multiplayer):
		_send_new_player_to_clients(player.id, game_player_id)


## Called when the "Start Game" button is pressed in the main menu.
## Loads the test map and starts the game.
func _on_game_start_requested(
		scenario_scene: PackedScene, rules: GameRules
) -> void:
	var world: Node = scenario_scene.instantiate()
	var scenario := world.get_node("Scenarios/Scenario1") as Scenario1
	load_game_from_scenario(scenario, rules)


## This function's name is a bit misleading, because it's precisely
## the function that makes you enter the main menu.
func _on_main_menu_entered() -> void:
	var main_menu := main_menu_scene.instantiate() as MainMenu
	main_menu.setup_players(players)
	main_menu.setup_chat(chat)
	main_menu.game_started.connect(_on_game_start_requested)
	_send_enter_main_menu_to_clients()
	current_scene = main_menu


## Send a global chat message when the game loop begins.
func _on_game_started() -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		chat.send_global_message("The game has started!")


# TODO Ugly code, shouldn't be here
## This is called when the user asks to create a new local player
## by clicking on the "add" button on the [TurnOrderList] interface.
## The newly created [Player] must be assigned to the given [GamePlayer].
func _on_game_new_player_requested(game_player: GamePlayer) -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		_add_new_player(game_player.id)
	else:
		_add_new_player.rpc_id(1, game_player.id)
