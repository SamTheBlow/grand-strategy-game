extends Node
## Runs a new [Game] loaded from given scenario scene, without any visuals,
## and lets the AIs play for 500 turns or until the game is over.
## Then, gives basic information about the game's outcome.


@export var scenario_scene: PackedScene

## If true, this node will have no effect.
@export var is_disabled: bool = false

## If true, the game will be saved after the game is over.
@export var save_the_game: bool = true

## The path for the save file. Irrelevant if save_the_game is false.
@export var save_file_path: String = "user://gamesave.json"

var _game: Game


func _ready() -> void:
	if is_disabled:
		return
	
	var world: Node = scenario_scene.instantiate()
	var scenario := world.get_node("Scenarios/Scenario1") as Scenario1
	
	var game_rules := GameRules.new()
	game_rules.turn_limit_enabled.value = true
	game_rules.turn_limit.value = 500
	
	var game_from_scenario := GameFromScenario.new()
	game_from_scenario.load_game(scenario, game_rules)
	_game = game_from_scenario.result
	
	print("[HeadlessGameTest] Running the game...")
	_game.turn.turn_changed.connect(_on_turn_changed)
	_game.game_over.connect(_on_game_over)
	_game.start()


func _on_turn_changed(turn: int) -> void:
	print("[HeadlessGameTest] Turn ", turn)


func _on_game_over(winner_country: Country) -> void:
	_game.turn.stop()
	
	var debug_text: String = "[HeadlessGameTest] "
	debug_text += (
			"The game is over! The winner is "
			+ winner_country.country_name + ".\n"
			+ "The game lasted " + str(_game.turn.current_turn() - 1)
			+ " turn(s)."
	)
	
	var pcpc := ProvinceCountPerCountry.new()
	pcpc.calculate(_game.world.provinces.list())
	for i in pcpc.countries.size():
		debug_text += (
				"\n- " + pcpc.countries[i].country_name + " controls "
				+ str(pcpc.number_of_provinces[i]) + " province(s)."
		)
	
	print(debug_text)
	
	if save_the_game:
		var game_save := GameSave.new()
		game_save.save_game(_game, save_file_path)
		
		if game_save.error:
			print(
					"[HeadlessGameTest] Failed to save the game: ",
					game_save.error_message
			)
		else:
			print("[HeadlessGameTest] Game saved!")
