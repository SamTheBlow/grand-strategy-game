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
## The scene to jump to when entering the play menu.
## Its root node must be a [PlayMenu].
@export var play_menu_scene: PackedScene
## The scene to jump to when entering a game.
## Its root node must be a [GameNode].
@export var game_scene: PackedScene
## The scene to jump to when entering the editor.
## Its root node must be an [Editor].
@export var editor_scene: PackedScene

## Setting this automatically removes the previous scene
## from the scene tree and adds the new scene to the scene tree.
var current_scene: Node:
	set(value):
		if current_scene != null:
			current_scene.queue_free()

		current_scene = value
		add_child(current_scene)
		_send_scene_change_to_clients()

# Things that need to persist between scenes
var game_menu_state := GameSelectMenuState.new()
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
	main_menu.play_clicked.connect(enter_play_menu)
	main_menu.make_clicked.connect(enter_editor)
	current_scene = main_menu


func enter_play_menu() -> void:
	if current_scene is PlayMenu:
		return

	var play_menu := play_menu_scene.instantiate() as PlayMenu
	play_menu.inject(players, game_menu_state, rule_menu_state, chat)
	play_menu.game_started.connect(_on_game_start_requested)
	current_scene = play_menu


## Assigns [Player]s to the game's [GamePlayer]s.
## Sets up a new [GameNode] scene using given [GameProject].
## Starts the game.
func play_game(project: GameProject) -> void:
	project.game.game_started.connect(_on_game_started)
	players.player_removed.connect(project.game.game_players._on_player_removed)
	project.metadata.file_path = SAVE_FILE_PATH

	var game_node := game_scene.instantiate() as GameNode
	game_node.project = project
	game_node.players = players
	game_node.chat = chat
	game_node.exited.connect(enter_play_menu)
	current_scene = game_node


## Tries to load a [GameProject] at the default save file path.
## If it fails, sends a system message in the chat.
## If it succeeds, sends a global message in the chat
## and loads the new game scene.
func load_game() -> void:
	var result: ProjectParsing.ParseResult = (
			ProjectFromPath.loaded_from(SAVE_FILE_PATH)
	)

	if result.error:
		push_warning(
				"Failed to load the game: ", result.error_message
		)
		chat.send_system_message("Failed to load the game")
		return

	chat.send_global_message("[color=#60ff60]Game loaded[/color]")
	play_game(result.result_project)


func enter_editor() -> void:
	if current_scene is Editor:
		return

	var editor := editor_scene.instantiate() as Editor
	editor.exited.connect(enter_main_menu)
	current_scene = editor


func _send_scene_change_to_clients() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	if current_scene is PlayMenu:
		_send_enter_main_menu_to_clients()
	elif current_scene is GameNode:
		_send_game_to_clients((current_scene as GameNode).project)
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
func _send_game_to_clients(
		project: GameProject, multiplayer_id: int = -1
) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	var game_raw_dict: Dictionary = (
			GameParsing.game_to_raw_dict(project.game, project.settings)
	)

	if multiplayer_id == -1:
		_receive_new_game.rpc(game_raw_dict)
	else:
		_receive_new_game.rpc_id(multiplayer_id, game_raw_dict)


## The client receives a new game from the server.
## The game is built from the given raw data, then we wait
## until we've received everything else before we start the game.
@rpc("authority", "call_remote", "reliable")
func _receive_new_game(raw_data: Dictionary) -> void:
	var project_from_raw: ProjectParsing.ParseResult = (
			ProjectParsing.parsed_from(raw_data, "")
	)

	if project_from_raw.error:
		push_warning(
				"Failed to load the received game: ",
				project_from_raw.error_message
		)
		chat.send_system_message("Failed to load the received game.")
		return

	# Make sure everything is done synchronizing (e.g. players, chat).
	if sync_check.is_sync_finished():
		play_game(project_from_raw.result_project)
	else:
		sync_check.sync_finished.connect(
				_on_sync_finished.bind(project_from_raw.result_project)
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
		_send_game_to_clients(
				(current_scene as GameNode).project, multiplayer_id
		)
	elif current_scene is PlayMenu:
		_send_enter_main_menu_to_clients(multiplayer_id)
	else:
		push_error("Unrecognized scene. Cannot sync scene with new client.")


## Clients start given game once they are done synchronizing with the server.
func _on_sync_finished(project: GameProject) -> void:
	sync_check.sync_finished.disconnect(_on_sync_finished)
	play_game(project)


## Called when the "Start Game" button is pressed in the main menu,
## after it's done loading/generating the game.
func _on_game_start_requested(project: GameProject) -> void:
	play_game(project)


## Sends a global chat message when the game starts.
func _on_game_started() -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		chat.send_global_message("The game has started!")
