extends Node
## The main class. Runs when the game is launched.
## Takes care of scene transitions and makes data persist across scenes.
# TODO move code to their own classes (scene transition, sync, etc)

# TODO move this to some new user settings class
## The default file path for the game's save file.
const SAVE_FILE_PATH: String = "user://gamesave.json"

## The scene to jump to when entering the main menu.
## Its root node must be a [MainMenu].
@export var main_menu_scene: PackedScene
## The scene to jump to when entering a game.
## Its root node must be a [GameNode].
@export var _game_scene: PackedScene

## Setting this automatically removes the previous scene
## from the scene tree and adds the new scene to the scene tree.
var current_scene: Node:
	set(value):
		if current_scene != null:
			remove_child(current_scene)
			current_scene.queue_free()

		current_scene = value
		add_child(current_scene)
		_send_scene_change_to_clients()

# Things that need to persist between scenes
var map_menu_state := MapMenuState.new()
var rule_menu_state := GameRules.new()
@onready var network_authentication := %NetworkAuthentication as ClientAuth
@onready var players := $Players as Players
@onready var chat := $Chat as Chat

## This is to make sure that in online games,
## everything is properly synchronized before starting the game.
var sync_check := SyncCheck.new()


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_connected.connect(_on_multiplayer_peer_connected)

	# Add one player
	players.add_new_player()

	chat.send_global_message("Type /help to get a list of commands.")
	enter_main_menu()


func enter_main_menu() -> void:
	if current_scene is MainMenu:
		return

	var main_menu := main_menu_scene.instantiate() as MainMenu
	main_menu.inject(players, map_menu_state, rule_menu_state, chat)
	main_menu.game_started.connect(_on_game_start_requested)
	current_scene = main_menu


## Assigns [Player]s to the game's [GamePlayer]s.
## Sets up a new [GameNode] scene using given [Game].
## Starts the game.
func play_game(game: Game) -> void:
	game.game_started.connect(_on_game_started)
	players.player_removed.connect(game.game_players._on_player_removed)

	var game_node := _game_scene.instantiate() as GameNode
	game_node.game = game
	game_node.players = players
	game_node.chat = chat
	game_node.exited.connect(_on_main_menu_requested)
	current_scene = game_node


## Tries to load a game at the default save file path.
## If it fails, sends a system message in the chat.
## If it succeeds, sends a global message in the chat
## and loads the new game scene.
func load_game() -> void:
	var game_from_path := GameFromPath.new()
	game_from_path.load_game(SAVE_FILE_PATH)

	if game_from_path.error:
		push_warning("Failed to load the game: ", game_from_path.error_message)
		chat.send_system_message("Failed to load the game")
		return

	chat.send_global_message("[color=#60ff60]Game loaded[/color]")
	play_game(game_from_path.result)


func _send_scene_change_to_clients() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	if current_scene is MainMenu:
		_send_enter_main_menu_to_clients()
	elif current_scene is GameNode:
		_send_game_to_clients((current_scene as GameNode).game)
	else:
		push_error("Unrecognized scene node.")


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
	enter_main_menu()
#endregion


#region Inform clients that a game started
## The server calls this to inform clients that a game started.
## This function has no effect if you're not connected as a server.
## You may provide a multiplayer id to send the data to one specific client.
func _send_game_to_clients(game: Game, multiplayer_id: int = -1) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	var game_to_raw := GameToRawDict.new()
	game_to_raw.convert_game(game)
	if game_to_raw.error:
		push_error(
				"Failed to convert game into raw data: ",
				game_to_raw.error_message
		)
		chat.send_system_message("Failed to send the game to other players.")
		return

	if multiplayer_id == -1:
		_receive_new_game.rpc(game_to_raw.result)
	else:
		_receive_new_game.rpc_id(multiplayer_id, game_to_raw.result)


## The client receives a new game from the server.
## The game is built from the given raw data, then we wait
## until we've received everything else before we start the game.
@rpc("authority", "call_remote", "reliable")
func _receive_new_game(game_data: Dictionary) -> void:
	var game_from_raw := GameFromRawDict.new()
	game_from_raw.load_game(game_data)

	if game_from_raw.error:
		push_warning(
				"Failed to load the received game: ",
				game_from_raw.error_message
		)
		chat.send_system_message("Failed to load the received game.")
		return

	# Make sure everything is done synchronizing (e.g. players, chat).
	if sync_check.is_sync_finished():
		play_game(game_from_raw.result)
	else:
		sync_check.sync_finished.connect(
				_on_sync_finished.bind(game_from_raw.result)
		)
#endregion


func _on_connected_to_server() -> void:
	sync_check = PlayersSyncCheck.new(players)


## The server informs the new client of which scene we're currently in.
## If we're in a game, sends them the game data.
func _on_multiplayer_peer_connected(multiplayer_id: int) -> void:
	if not multiplayer.is_server():
		return

	if current_scene is GameNode:
		_send_game_to_clients((current_scene as GameNode).game, multiplayer_id)
	elif current_scene is MainMenu:
		_send_enter_main_menu_to_clients(multiplayer_id)
	else:
		push_error("Unrecognized scene. Cannot sync scene with new client.")


## Clients start given game once they are done synchronizing with the server.
func _on_sync_finished(game: Game) -> void:
	sync_check.sync_finished.disconnect(_on_sync_finished)
	play_game(game)


func _on_main_menu_requested() -> void:
	enter_main_menu()


## Called when the "Start Game" button is pressed in the main menu,
## after it's done loading/generating the game.
func _on_game_start_requested(game: Game) -> void:
	play_game(game)


## Sends a global chat message when the game starts.
func _on_game_started() -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		chat.send_global_message("The game has started!")
