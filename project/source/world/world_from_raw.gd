class_name WorldFromRaw
## Converts raw data into a [GameWorld].
## Many things in the game must be loaded before using this.
## Please read the code carefully to know what to load first (sorry!)
## Overwrites the game's world property.
##
## This operation always succeeds.
## Ignores unrecognized data.

const WORLD_LIMITS_KEY: String = "limits"
const WORLD_PROVINCES_KEY: String = "provinces"
const WORLD_ARMIES_KEY: String = "armies"


static func parse_using(
		raw_data: Variant, game: Game, game_settings: GameSettings
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
