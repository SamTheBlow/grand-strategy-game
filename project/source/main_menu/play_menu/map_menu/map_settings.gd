class_name MapSettings
extends Control
## Interface where the user can configure a map's individual settings.

const KEY_TYPE: String = "type"
const KEY_TEXT: String = "text"
const KEY_VALUE: String = "value"
const KEY_OPTIONS: String = "options"

## The spacing to add at the bottom, in pixels.
@export var spacing_bottom: float = 16.0

@export var bool_scene: PackedScene
@export var int_scene: PackedScene
@export var float_scene: PackedScene
@export var options_scene: PackedScene

var map_metadata: MapMetadata:
	set(value):
		if map_metadata == value:
			return

		_disconnect_signals()
		map_metadata = value
		_connect_signals()
		_update_settings_list()

var _is_empty: bool = true

@onready var _settings_container := %SettingsContainer as Control


func _ready() -> void:
	_update_settings_list()


## Returns true if there are no settings.
func is_empty() -> bool:
	return _is_empty


func _update_settings_list() -> void:
	if map_metadata == null or not is_node_ready():
		return

	NodeUtils.remove_all_children(_settings_container)
	_is_empty = true

	var minimum_height: float = 0.0

	for key: Variant in map_metadata.settings:
		if key is not String:
			continue
		var key_string := key as String
		var value: Variant = map_metadata.settings[key]
		if value is not Dictionary:
			continue
		var value_dict := value as Dictionary

		if not ParseUtils.dictionary_has_string(value_dict, KEY_TYPE):
			continue
		var value_type: String = value_dict[KEY_TYPE]

		var value_text: String = key_string
		if ParseUtils.dictionary_has_string(value_dict, KEY_TEXT):
			value_text = value_dict[KEY_TEXT]

		var setting_node: Control
		match value_type:
			"bool":
				var default_value: bool
				if ParseUtils.dictionary_has_bool(value_dict, KEY_VALUE):
					default_value = value_dict[KEY_VALUE]

				var setting := bool_scene.instantiate() as SettingBoolNode
				setting.key = key_string
				setting.value = default_value
				setting.text = value_text
				setting.value_changed.connect(_on_setting_changed)
				setting_node = setting
			"int":
				var default_value: int
				if ParseUtils.dictionary_has_number(value_dict, KEY_VALUE):
					default_value = (
							ParseUtils.dictionary_int(value_dict, KEY_VALUE)
					)

				var setting := int_scene.instantiate() as SettingIntNode
				setting.key = key_string
				setting.value = default_value
				setting.text = value_text
				setting.value_changed.connect(_on_setting_changed)
				setting_node = setting
			"float":
				var default_value: float
				if ParseUtils.dictionary_has_number(value_dict, KEY_VALUE):
					default_value = (
							ParseUtils.dictionary_float(value_dict, KEY_VALUE)
					)

				var setting := float_scene.instantiate() as SettingFloatNode
				setting.key = key_string
				setting.value = default_value
				setting.text = value_text
				setting.value_changed.connect(_on_setting_changed)
				setting_node = setting
			"options":
				var default_value: int = 0
				if ParseUtils.dictionary_has_number(value_dict, KEY_VALUE):
					default_value = (
							ParseUtils.dictionary_int(value_dict, KEY_VALUE)
					)

				var options: Array[String] = []
				if ParseUtils.dictionary_has_array(value_dict, KEY_OPTIONS):
					var array: Array = value_dict[KEY_OPTIONS]
					for element: Variant in array:
						if element is String:
							options.append(element)

				if default_value >= options.size() or default_value < 0:
					default_value = 0

				if options.size() > 0:
					var setting := (
							options_scene.instantiate() as SettingOptionsNode
					)
					setting.key = key_string
					setting.value = default_value
					setting.text = value_text
					setting.options = options
					setting.value_changed.connect(_on_setting_changed)
					setting_node = setting

		if setting_node == null:
			continue

		var h_box_container := HBoxContainer.new()
		_settings_container.add_child(h_box_container)

		h_box_container.add_child(setting_node)

		if minimum_height > 0.0:
			minimum_height += 8
		minimum_height += setting_node.size.y

		_is_empty = false

	custom_minimum_size.y = minimum_height + spacing_bottom


func _connect_signals() -> void:
	if map_metadata == null:
		return

	if not map_metadata.state_updated.is_connected(_on_state_updated):
		map_metadata.state_updated.connect(_on_state_updated)


func _disconnect_signals() -> void:
	if map_metadata == null:
		return

	if map_metadata.state_updated.is_connected(_on_state_updated):
		map_metadata.state_updated.disconnect(_on_state_updated)


func _on_setting_changed(key: String, value: Variant) -> void:
	if map_metadata == null:
		return

	map_metadata.set_setting(key, value)


func _on_state_updated(_map_metadata: MapMetadata) -> void:
	_update_settings_list()
