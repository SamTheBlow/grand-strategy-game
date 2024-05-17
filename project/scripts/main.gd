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
	chat.send_global_message("Type /help to get a list of commands.")
	
	_on_main_menu_entered()


func load_game() -> void:
	var game_from_path := GameFromPath.new()
	game_from_path.load_game(SAVE_FILE_PATH, game_scene)
	
	if game_from_path.error:
		print_debug(game_from_path.error_message)
		return
	
	play_game(game_from_path.result)


func load_game_from_scenario(scenario: Scenario1, rules: GameRules) -> void:
	var game_from_scenario := GameFromScenario.new()
	game_from_scenario.load_game(scenario, rules, players, game_scene)
	
	if game_from_scenario.error:
		print_debug(game_from_scenario.error_message)
		return
	
	play_game(game_from_scenario.result)


func play_game(game: Game) -> void:
	game.game_started.connect(_on_game_started)
	game.game_ended.connect(_on_main_menu_entered)
	game.chat = chat
	_send_new_game_to_clients(game)
	current_scene = game
	game.start()


# TODO DRY: copy/pasted from players.gd
## Returns true if (and only if) you are connected.
func _is_connected() -> bool:
	return (
			multiplayer
			and multiplayer.has_multiplayer_peer()
			and multiplayer.multiplayer_peer.get_connection_status()
			== MultiplayerPeer.CONNECTION_CONNECTED
	)


#region Inform clients that a game started
## The server calls this to inform clients that a game started.
## This function has no effect if you're not connected as a server.
func _send_new_game_to_clients(game: Game) -> void:
	if not (_is_connected() and multiplayer.is_server()):
		return
	
	var game_to_json := GameToJSON.new()
	game_to_json.convert_game(game)
	if game_to_json.error:
		print_debug(
				"Error converting game to JSON: "
				+ game_to_json.error_message
		)
		return
	
	_receive_new_game.rpc(game_to_json.result)


@rpc("authority", "call_remote", "reliable")
func _receive_new_game(game_json: Dictionary) -> void:
	var game_from_json := GameFromJSON.new()
	game_from_json.load_game(game_json, game_scene)
	
	if game_from_json.error:
		print_debug(game_from_json.error_message)
		return
	
	game_from_json.result.init2()
	play_game(game_from_json.result)
#endregion


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
	current_scene = main_menu


func _on_game_started() -> void:
	if (not _is_connected()) or multiplayer.is_server():
		chat.send_global_message("The game begins!")
