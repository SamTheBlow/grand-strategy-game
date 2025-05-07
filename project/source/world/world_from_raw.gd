class_name WorldFromRaw
## Converts raw data into a [GameWorld].
## Many things in the game must be loaded before using this.
## Please read the code carefully to know what to load first (sorry!)
## Overwrites the game's world property.
##
## This operation always succeeds.
## Ignores unrecognized data.

const WORLD_ARMIES_KEY: String = "armies"
const WORLD_DECORATIONS_KEY: String = "decorations"
const WORLD_LIMITS_KEY: String = "limits"
const WORLD_PROVINCES_KEY: String = "provinces"


static func parse_using(
		raw_data: Variant,
		game: Game,
		game_settings: GameSettings,
		project_file_path: String
) -> void:
	game.world = GameWorld.new(game)

	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# Provinces
	ProvincesFromRaw.parse_using(raw_dict.get(WORLD_PROVINCES_KEY), game)

	# Armies
	ArmiesFromRaw.parse_using(raw_dict.get(WORLD_ARMIES_KEY), game)

	# World limits (must be loaded after the provinces)
	game_settings.load_world_limits(
			game.world,
			WorldLimitsFromRaw.parsed_from(raw_dict.get(WORLD_LIMITS_KEY))
	)

	# Decorations
	var parse_result := WorldDecorationsFromRaw.parsed_from(
			raw_dict.get(WORLD_DECORATIONS_KEY), project_file_path
	)
	if not parse_result.invalid_file_paths.is_empty():
		push_warning(
				"Got "
				+ str(parse_result.invalid_file_paths.size())
				+ " invalid file path(s) while loading world decorations"
		)
	game.world.decorations = parse_result.decorations
