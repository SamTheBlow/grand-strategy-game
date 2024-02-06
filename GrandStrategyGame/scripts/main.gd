extends Node


const SAVE_FILE_PATH: String = "user://gamesave.json"

@export var main_menu_scene: PackedScene
@export var game_scene: PackedScene


func _ready() -> void:
	_on_main_menu_entered()


func _on_game_started(scenario_scene: PackedScene, rules: GameRules) -> void:
	load_game_from_scenario(scenario_scene, rules)


func _on_main_menu_entered() -> void:
	_remove_all_children()
	
	var main_menu := main_menu_scene.instantiate() as MainMenu
	main_menu.game_started.connect(_on_game_started)
	add_child(main_menu)


func load_game() -> void:
	var game_from_path := GameFromPath.new()
	game_from_path.load_game(SAVE_FILE_PATH)
	
	if game_from_path.error:
		print_debug(game_from_path.error_message)
		return
	
	var game: Game = game_from_path.result
	
	_remove_all_children()
	game.game_ended.connect(_on_main_menu_entered)
	add_child(game)
	return


## Temporary function. Returns true if it succeeded, otherwise false.
func load_game_from_scenario(scenario_scene: PackedScene, rules: GameRules) -> bool:
	var game := game_scene.instantiate() as Game
	game.init()
	
	var world: Node = scenario_scene.instantiate()
	var scenario := world.get_node("Scenarios/Scenario1") as Scenario1
	game.load_from_scenario(scenario, rules)
	
	_remove_all_children()
	game.game_ended.connect(_on_main_menu_entered)
	add_child(game)
	return true


func _remove_all_children() -> void:
	for child in get_children():
		remove_child(child)
