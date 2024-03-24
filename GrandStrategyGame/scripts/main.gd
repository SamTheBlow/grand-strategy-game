extends Node
## Class responsible for scene transitions.


const SAVE_FILE_PATH: String = "user://gamesave.json"

@export var main_menu_scene: PackedScene
@export var game_scene: PackedScene


func _ready() -> void:
	_on_main_menu_entered()


func load_game() -> void:
	var game_from_path := GameFromPath.new()
	game_from_path.load_game(SAVE_FILE_PATH, game_scene)
	
	if game_from_path.error:
		print_debug(game_from_path.error_message)
		return
	
	play_game(game_from_path.result)


func load_game_from_scenario(
		scenario: Scenario1, rules: GameRules, players: Players
) -> void:
	var game_from_scenario := GameFromScenario.new()
	game_from_scenario.load_game(scenario, rules, players, game_scene)
	
	if game_from_scenario.error:
		print_debug(game_from_scenario.error_message)
		return
	
	play_game(game_from_scenario.result)


func play_game(game: Game) -> void:
	_remove_all_children()
	game.game_ended.connect(_on_main_menu_entered)
	add_child(game)


func _remove_all_children() -> void:
	for child in get_children():
		remove_child(child)


func _on_game_started(
		scenario_scene: PackedScene,
		rules: GameRules,
		players: Players
) -> void:
	var world: Node = scenario_scene.instantiate()
	var scenario := world.get_node("Scenarios/Scenario1") as Scenario1
	load_game_from_scenario(scenario, rules, players)


func _on_main_menu_entered() -> void:
	_remove_all_children()
	
	var main_menu := main_menu_scene.instantiate() as MainMenu
	main_menu.game_started.connect(_on_game_started)
	add_child(main_menu)
