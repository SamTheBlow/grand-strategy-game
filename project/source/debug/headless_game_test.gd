extends MainLoop
## Runs a new [Game] from given file path, without any visuals,
## and lets the AIs play for given number of turns or until the game is over.
## Then, gives basic information about the game's outcome.
##
## This script is meant to be run inside a terminal.
## To use, open a terminal inside the project's
## root folder (where the project.godot is), and run this command:
## [the path to your godot executable] --headless -s [the path to this file]


const ARG_TURN_LIMIT: String = "turnlimit"
const ARG_SAVE: String = "savegame"


## Command line argument: "++turnlimit=500"
var turn_limit: int = 500

## The file path of the game to load.
var load_file_path: String = "res://assets/save_files/test3.json"

## If true, the game will be saved after the game is over.
## Command line argument: "++savegame" sets this to true.
var save_the_game: bool = false

## The path for the save file. Irrelevant if save_the_game is false.
var save_file_path: String = "user://gamesave.json"

var _game: Game
var _is_finished: bool = false
var _previous_time_ticks: int


func _initialize() -> void:
	_load_cmdline_args()

	var game_rules := GameRules.new()
	game_rules.turn_limit_enabled.value = true
	game_rules.turn_limit.value = turn_limit

	_print_with_time("Generating the game...")

	var generated_game := GameLoadGenerated.new()
	generated_game.load_game(
			MapMetadata.from_file_path(load_file_path), game_rules
	)
	_game = generated_game.result

	_print_with_time("Running the game...")
	_game.turn.turn_changed.connect(_on_turn_changed)
	_game.game_over.connect(_on_game_over)
	_game.start()


func _process(_delta: float) -> bool:
	return _is_finished


func _load_cmdline_args() -> void:
	for arg in OS.get_cmdline_args():
		arg = arg.right(-2)
		if arg.begins_with(ARG_TURN_LIMIT):
			arg = arg.right(-ARG_TURN_LIMIT.length())
			if arg.begins_with("=") or arg.begins_with(" "):
				arg = arg.right(-1)
				if arg.is_valid_int():
					turn_limit = arg.to_int()
					print("Turn limit: ", turn_limit)
		elif arg.begins_with(ARG_SAVE):
			save_the_game = true
			print("The game will be saved at the end.")


func _print_with_time(message: String) -> void:
	var current_time_ticks: int = Time.get_ticks_usec()
	if _previous_time_ticks == 0:
		print(message)
	else:
		print(
				message,
				" (",
				_formatted_time(current_time_ticks - _previous_time_ticks),
				")"
		)
	_previous_time_ticks = current_time_ticks


func _formatted_time(elapsed_ticks_usec: int) -> String:
	if elapsed_ticks_usec < 1_000_000:
		return ("%.3f" % (elapsed_ticks_usec / 1000.0)) + " ms"
	if elapsed_ticks_usec < 60_000_000:
		return ("%.3f" % (elapsed_ticks_usec / 1_000_000.0)) + " seconds"
	if elapsed_ticks_usec < 3_600_000_000:
		return ("%.3f" % (elapsed_ticks_usec / 60_000_000.0)) + " minutes"
	return ("%.3f" % (elapsed_ticks_usec / 3_600_000_000.0)) + " hours"


func _on_turn_changed(turn: int) -> void:
	_print_with_time("Turn " + str(turn))


func _on_game_over(winner_country: Country) -> void:
	_game.turn.stop()

	var debug_text: String = ""
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
					"[ERROR] Failed to save the game: ",
					game_save.error_message
			)
		else:
			print("Game saved!")

	_is_finished = true
