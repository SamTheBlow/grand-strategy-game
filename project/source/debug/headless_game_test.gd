extends Node
## Runs a new [Game] from given file path, without any visuals,
## and lets the AIs play for 500 turns or until the game is over.
## Then, gives basic information about the game's outcome.


## The file path of the game to load.
@export var load_file_path: String = "res://assets/save_files/test1.json"

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

	var game_rules := GameRules.new()
	game_rules.turn_limit_enabled.value = true
	game_rules.turn_limit.value = 500

	# Temporary
	if load_file_path == "res://assets/save_files/test3.json":
		var generated_game := GameLoadGenerated.new()
		generated_game.load_game(
				MapMetadata.from_file_path(load_file_path), game_rules
		)
		_game = generated_game.result
	else:
		var populated_game := GameLoadPopulated.new()
		populated_game.load_game(load_file_path, game_rules)
		_game = populated_game.result

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
