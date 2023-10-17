extends Node


const SAVE_FILE_PATH: String = "user://gamesave.json"

@export var game_scene: PackedScene
@export var world_scene: PackedScene


func _ready():
	var world: Node = world_scene.instantiate()
	new_game(world, _game_state(world))
	
	var chat: Chat =  _chat()
	chat.connect(
			"load_requested",
			Callable(self, "_on_load_requested")
	)
	chat.connect(
			"save_requested",
			Callable(self, "_on_save_requested")
	)


func new_game(world: Node, game_state: GameState) -> void:
	if has_node("Game"):
		remove_child(get_node("Game"))
	
	var game := game_scene.instantiate() as Game
	add_child(game)
	game.load_world(world)
	game.load_game_state(game_state)


func _game_state(world: Node) -> GameState:
	var scenario := world.get_node("Scenarios/Scenario1") as Scenario1
	return scenario.generate_game_state()


func _chat() -> Chat:
	return get_node("Game/CanvasLayer/GameUI/Chat") as Chat


func _on_load_requested() -> void:
	var chat: Chat = _chat()
	
	var new_game_state: GameState = GameSaveJSON.new(SAVE_FILE_PATH).load_state()
	
	if new_game_state == null:
		var error_message: String = "Failed to load the game"
		push_error(error_message)
		chat.system_message(error_message)
		return
	
	new_game(world_scene.instantiate(), new_game_state)
	chat = _chat() # Get the new chat
	chat.new_message("[b]Game state loaded[/b]")


func _on_save_requested() -> void:
	var chat: Chat = _chat()
	
	var game_state: GameState = get_node("Game").game_state
	var error: int = (
			GameSaveJSON.new(SAVE_FILE_PATH).save_state(game_state)
	)
	
	if error != OK:
		var error_message: String = "Failed to save the game"
		push_error(error_message)
		chat.system_message(error_message)
		return
	
	chat.new_message("[b]Game state saved[/b]")
