class_name WorldParsing
## Parses raw data from/to a [GameWorld].

const _ARMIES_KEY: String = "armies"
const _PROVINCES_KEY: String = "provinces"
const _BACKGROUND_COLOR_KEY: String = "background_color"
const _DECORATIONS_KEY: String = "decorations"
const _LIMITS_KEY: String = "limits"
const _BUILDING_DATA_KEY: String = "building_data"


## NOTE: Many things in given game must be loaded before using this.
## Please read the code carefully to know what to load first (sorry!)
##
## Overwrites given game's world.
##
## Always succeeds. Ignores unrecognized data.
static func load_from_raw_data(
		raw_data: Variant, game: Game, project_textures: ProjectTextures
) -> void:
	game.world = GameWorld.new(game)

	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# World limits
	WorldLimitsParsing.load_from_raw_data(
			raw_dict.get(_LIMITS_KEY), game.world._limits
	)

	# Building data
	game.world._building_data_list = BuildingDataParsing.from_raw_data(
			raw_dict.get(_BUILDING_DATA_KEY),
			project_textures
	)

	# Provinces
	game.world._limits.set_automatic_update_enabled(false)
	ProvinceParsing.load_from_raw_data(raw_dict.get(_PROVINCES_KEY), game)
	game.world._limits.set_automatic_update_enabled(true)

	# Armies
	ArmyParsing.load_from_raw_data(
			raw_dict.get(_ARMIES_KEY), game, project_textures
	)

	# Background color
	game.world.background_color = ParseUtils.color_from_raw(
			raw_dict.get(_BACKGROUND_COLOR_KEY),
			GameWorld.default_clear_color()
	)

	# Decorations
	var parse_result := WorldDecorationParsing.from_raw_data(
			raw_dict.get(_DECORATIONS_KEY), project_textures
	)
	if not parse_result.invalid_file_paths.is_empty():
		push_warning(
				"Got ", parse_result.invalid_file_paths.size(),
				" invalid file path(s) while loading world decorations."
		)
	game.world.decorations = parse_result.decorations


static func to_raw_dict(world: GameWorld) -> Dictionary:
	var output: Dictionary = {}

	# Armies
	var armies_data: Array = ArmyParsing.to_raw_array(
			world.armies.list(), world.armies_in_each_province
	)
	if not armies_data.is_empty():
		output.merge({ _ARMIES_KEY: armies_data })

	# Provinces
	var provinces_data: Array = (
			ProvinceParsing.to_raw_array(world.provinces.list())
	)
	if not provinces_data.is_empty():
		output.merge({ _PROVINCES_KEY: provinces_data })

	# World limits
	var limits_data: Variant = world.limits().to_raw_data()
	if not ParseUtils.is_empty_dict(limits_data):
		output.merge({ _LIMITS_KEY: limits_data })

	# Background color
	if world.background_color != GameWorld.default_clear_color():
		output.merge({
			_BACKGROUND_COLOR_KEY: world.background_color.to_html(false)
		})

	# Decorations
	var decoration_data: Array = (
			WorldDecorationParsing.to_raw_array(world.decorations)
	)
	if not decoration_data.is_empty():
		output.merge({ _DECORATIONS_KEY: decoration_data })

	# Building data
	var building_data: Array = (
			BuildingDataParsing.to_raw_array(world._building_data_list)
	)
	if not building_data.is_empty():
		output.merge({ _BUILDING_DATA_KEY: building_data })

	return output
