@tool
class_name AppEditorSettings
extends Resource
## The app's editor settings.
##
## Note: do not confuse this with the built-in class [EditorSettings].

const _SHOW_WORLD_LIMITS_KEY: String = "show_world_limits"
const _WORLD_LIMITS_COLOR_KEY: String = "world_limits_color"
const _SHOW_DECORATIONS_KEY: String = "show_decorations"
const _SHOW_BUILDINGS_KEY: String = "show_buildings"

@export var show_world_limits: ItemBool:
	set(value):
		show_world_limits = value
		show_world_limits.value_changed.connect(emit_changed.unbind(1))

@export var world_limits_color: ItemColor:
	set(value):
		world_limits_color = value
		world_limits_color.value_changed.connect(emit_changed.unbind(1))

@export var show_decorations: ItemBool:
	set(value):
		show_decorations = value
		show_decorations.value_changed.connect(emit_changed.unbind(1))

@export var show_buildings: ItemBool:
	set(value):
		show_buildings = value
		show_buildings.value_changed.connect(emit_changed.unbind(1))


func to_raw_data() -> Dictionary:
	var output: Dictionary = {}
	output[_SHOW_WORLD_LIMITS_KEY] = show_world_limits.get_data()
	output[_WORLD_LIMITS_COLOR_KEY] = world_limits_color.get_data().to_html()
	output[_SHOW_DECORATIONS_KEY] = show_decorations.get_data()
	output[_SHOW_BUILDINGS_KEY] = show_buildings.get_data()
	return output


func load_raw_data(raw_data: Variant) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	if ParseUtils.dictionary_has_bool(raw_dict, _SHOW_WORLD_LIMITS_KEY):
		show_world_limits.set_data(raw_dict[_SHOW_WORLD_LIMITS_KEY])

	world_limits_color.set_data(ParseUtils.color_from_raw(
			raw_dict.get(_WORLD_LIMITS_COLOR_KEY),
			world_limits_color.get_data()
	))

	if ParseUtils.dictionary_has_bool(raw_dict, _SHOW_DECORATIONS_KEY):
		show_decorations.set_data(raw_dict[_SHOW_DECORATIONS_KEY])

	if ParseUtils.dictionary_has_bool(raw_dict, _SHOW_BUILDINGS_KEY):
		show_buildings.set_data(raw_dict[_SHOW_BUILDINGS_KEY])
