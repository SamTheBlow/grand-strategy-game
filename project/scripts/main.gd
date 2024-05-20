extends Node
## Class responsible for scene transitions.


const SAVE_FILE_PATH: String = "user://gamesave.json"

@export var main_menu_scene: PackedScene
@export var game_scene: PackedScene

## Automatically removes the previous scene from the scene tree
## and adds the given scene to the scene tree.
var current_scene: Node:
	set(value):
		if current_scene:
			remove_child(current_scene)
			current_scene.queue_free()
		current_scene = value
		add_child(current_scene)

@onready var players := $Players as Players
@onready var chat := $Chat as Chat


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_multiplayer_peer_connected)
	
	chat.send_global_message("Type /help to get a list of commands.")
	
	_on_main_menu_entered()


func load_game() -> void:
	var game_from_path := GameFromPath.new()
	game_from_path.load_game(SAVE_FILE_PATH, game_scene)
	
	if game_from_path.error:
		chat.send_system_message("Failed to load the game")
		print_debug(game_from_path.error_message)
		return
	
	chat.send_global_message("[color=#60ff60]Game loaded[/color]")
	play_game(game_from_path.result)


func load_game_from_scenario(scenario: Scenario1, rules: GameRules) -> void:
	var game_from_scenario := GameFromScenario.new()
	game_from_scenario.load_game(scenario, rules, game_scene)
	
	if game_from_scenario.error:
		print_debug(game_from_scenario.error_message)
		return
	
	play_game(game_from_scenario.result)


func play_game(game: Game) -> void:
	game.game_started.connect(_on_game_started)
	game.game_ended.connect(_on_main_menu_entered)
	game.chat = chat
	game.setup_players(players)
	_send_new_game_to_clients(game)
	current_scene = game
	game.start()


#region Inform clients that a game started
## The server calls this to inform clients that a game started.
## This function has no effect if you're not connected as a server.
## You may provide a multiplayer id to send the data to one specific client.
func _send_new_game_to_clients(game: Game, multiplayer_id: int = -1) -> void:
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


@rpc("authority", "call_remote", "reliable")
func _receive_new_game(game_json: Dictionary) -> void:
	var game_from_json := GameFromJSON.new()
	game_from_json.load_game(game_json, game_scene)
	
	if game_from_json.error:
		print_debug(game_from_json.error_message)
		return
	
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


@rpc("authority", "call_remote", "reliable")
func _receive_enter_main_menu() -> void:
	_on_main_menu_entered()
#endregion


func _on_multiplayer_peer_connected(multiplayer_id: int) -> void:
	if not multiplayer.is_server():
		return
	
	if current_scene is Game:
		_send_new_game_to_clients(current_scene, multiplayer_id)
	elif current_scene is MainMenu:
		_send_enter_main_menu_to_clients(multiplayer_id)
	else:
		print_debug("Unrecognized scene. Cannot sync scene with new client.")


func _on_game_start_requested(
		scenario_scene: PackedScene, rules: GameRules
) -> void:
	var world: Node = scenario_scene.instantiate()
	var scenario := world.get_node("Scenarios/Scenario1") as Scenario1
	load_game_from_scenario(scenario, rules)


func _on_main_menu_entered() -> void:
	var main_menu := main_menu_scene.instantiate() as MainMenu
	main_menu.setup_players(players)
	main_menu.setup_chat(chat)
	main_menu.game_started.connect(_on_game_start_requested)
	_send_enter_main_menu_to_clients()
	current_scene = main_menu


func _on_game_started() -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		chat.send_global_message("The game has started!")
