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
	game.game_ended.connect(_on_main_menu_entered)
	game.chat = chat
	current_scene = game
	game.start()


func _on_game_started(scenario_scene: PackedScene, rules: GameRules) -> void:
	var world: Node = scenario_scene.instantiate()
	var scenario := world.get_node("Scenarios/Scenario1") as Scenario1
	load_game_from_scenario(scenario, rules)


func _on_main_menu_entered() -> void:
	var main_menu := main_menu_scene.instantiate() as MainMenu
	main_menu.setup_players(players)
	main_menu.setup_chat(chat)
	main_menu.game_started.connect(_on_game_started)
	current_scene = main_menu
