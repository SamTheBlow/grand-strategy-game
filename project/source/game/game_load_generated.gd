class_name GameLoadGenerated
## Loads a [Game] from given [GameMetadata].
## When applicable, generates the world, countries, etc.
## Then, populates the game (see [PopulatedSaveFile]).

var error: bool = true
var error_message: String = ""
var result: Game
var result_settings: GameSettings


## Upon loading, overwrites the game's rules with given rules.
func load_game(metadata: GameMetadata, game_rules: GameRules) -> void:
	# Load the file
	var file_json := FileJSON.new()
	file_json.load_json(metadata.file_path)
	if file_json.error:
		error = true
		error_message = file_json.error_message
		return

	# Generate data, if applicable
	var game_generation: GameGeneration = null
	if metadata.project_name == "Random Grid World":
		game_generation = RandomGridWorld.new()

	if game_generation != null:
		game_generation.load_settings(metadata.settings)
		if game_generation.error:
			error = true
			error_message = game_generation.error_message
			return
		game_generation.apply(file_json.result)

	# Load the game
	var game_from_raw: GameFromRaw.ParseResult = (
			GameFromRaw.parsed_from(file_json.result, metadata.file_path)
	)
	if game_from_raw.error:
		error = true
		error_message = game_from_raw.error_message
		return
	var game: Game = game_from_raw.result_game

	# Overwrite the rules
	game.rules = game_rules

	# Populate the game
	PopulatedSaveFile.apply(game)

	# Success!
	error = false
	result = game
	result_settings = game_from_raw.result_settings
