extends Node


const SAVE_FILE_PATH: String = "user://gamesave.json"

@export var main_menu_scene: PackedScene
@export var game_scene: PackedScene


func _ready() -> void:
	_on_main_menu_entered()


func _on_game_started(scenario_scene: PackedScene, rules: GameRules) -> void:
	var world: Node = scenario_scene.instantiate()
	var scenario := world.get_node("Scenarios/Scenario1") as Scenario1
	var your_id: int = scenario.human_player
	var game_state: GameState = (
			scenario.generate_game_state(rules)
	)
	new_game(game_state, your_id)
	
	var chat: Chat = _chat()
	chat.connect(
			"load_requested",
			Callable(self, "_on_load_requested")
	)
	chat.connect(
			"save_requested",
			Callable(self, "_on_save_requested")
	)
	chat.connect(
			"exit_to_main_menu_requested",
			Callable(self, "_on_main_menu_entered")
	)


func _on_main_menu_entered() -> void:
	_remove_all_children()
	
	var main_menu: Node = main_menu_scene.instantiate()
	main_menu.connect("game_started", Callable(self, "_on_game_started"))
	add_child(main_menu)


func new_game(game_state: GameState, your_id: int) -> void:
	_remove_all_children()
	
	var game := game_scene.instantiate() as Game
	game.load_game_state(game_state, your_id)
	add_child(game)


func _chat() -> Chat:
	return (get_node("Game") as Game).chat as Chat


func _on_load_requested() -> void:
	var chat: Chat = _chat()
	
	var new_game_state: GameState = GameSaveJSON.new(SAVE_FILE_PATH).load_state()
	
	if new_game_state == null:
		var error_message: String = "Failed to load the game"
		push_error(error_message)
		chat.system_message(error_message)
		return
	
	new_game(new_game_state, randi() % new_game_state.players.players.size())
	chat = _chat() # Get the new chat
	# TODO bad code DRY
	chat.connect(
			"load_requested", Callable(self, "_on_load_requested")
	)
	chat.connect(
			"save_requested", Callable(self, "_on_save_requested")
	)
	chat.new_message("[b]Game state loaded[/b]")


func _on_save_requested() -> void:
	var chat: Chat = _chat()
	
	var game_state: GameState = (get_node("Game") as Game)._game_state
	var error: int = (
			GameSaveJSON.new(SAVE_FILE_PATH).save_state(game_state)
	)
	
	if error != OK:
		var error_message: String = "Failed to save the game"
		push_error(error_message)
		chat.system_message(error_message)
		return
	
	chat.new_message("[b]Game state saved[/b]")


func _remove_all_children() -> void:
	for child in get_children():
		remove_child(child)
