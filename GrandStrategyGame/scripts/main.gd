extends Node


const SAVE_FILE_PATH: String = "user://gamesave.json"

@export var main_menu_scene: PackedScene
@export var game_scene: PackedScene


func _ready() -> void:
	_on_main_menu_entered()


func _on_game_started(scenario_scene: PackedScene, rules: GameRules) -> void:
	var world: Node = scenario_scene.instantiate()
	var scenario := world.get_node("Scenarios/Scenario1") as Scenario1
	
	var game_state: GameState = scenario.generate_game_state(rules)
	var your_id: int = scenario.human_player
	new_game(game_state, your_id)


func _on_main_menu_entered() -> void:
	_remove_all_children()
	
	var main_menu := main_menu_scene.instantiate() as MainMenu
	main_menu.game_started.connect(_on_game_started)
	add_child(main_menu)


func new_game(game_state: GameState, your_id: int) -> void:
	_remove_all_children()
	
	var game := game_scene.instantiate() as Game
	game.load_game_state(game_state, your_id)
	game.game_ended.connect(_on_main_menu_entered)
	add_child(game)


func _remove_all_children() -> void:
	for child in get_children():
		remove_child(child)
