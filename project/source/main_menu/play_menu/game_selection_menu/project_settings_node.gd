class_name ProjectSettingsNode
extends Control
## Interface where the user can configure a project's individual settings.

const KEY_TYPE: String = "type"
const KEY_TEXT: String = "text"
const KEY_VALUE: String = "value"
const KEY_OPTIONS: String = "options"

## The spacing to add at the bottom, in pixels.
@export var spacing_bottom: float = 16.0

var metadata: GameMetadata:
	set(value):
		if metadata == value:
			return

		_disconnect_signals()
		metadata = value
		_connect_signals()
		_update_settings_list()

## Each key is a [PropertyTreeItem] and each value is the key used
## to refer to this item in the custom settings data.
# I'd make this a static Dictionary[PropertyTreeItem, String]
# but Godot won't let us use subclasses of [PropertyTreeItem] as keys ._.
var _item_keys: Dictionary = {}

var _is_empty: bool = true

@onready var _settings_container := %SettingsContainer as Control


func _ready() -> void:
	_update_settings_list()


## Returns true if there are no settings.
func is_empty() -> bool:
	return _is_empty


func _update_settings_list() -> void:
	if metadata == null or not is_node_ready():
		return

	NodeUtils.remove_all_children(_settings_container)
	_item_keys.clear()
	_is_empty = true

	var minimum_height: float = 0.0

	for key: Variant in metadata.settings:
		if key is not String:
			continue
		var key_string: String = key
		var value: Variant = metadata.settings[key]
		if value is not Dictionary:
			continue
		var value_dict: Dictionary = value

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

				var setting := (
						preload("uid://bo8oke3mld227").instantiate()
						as ItemBoolNode
				)
				setting.item = ItemBool.new()
				setting.item.value = default_value
				setting.item.text = value_text
				_item_keys[setting.item] = key_string
				setting.item.value_changed.connect(_on_setting_changed)
				setting_node = setting
			"int":
				var default_value: int
				if ParseUtils.dictionary_has_number(value_dict, KEY_VALUE):
					default_value = (
							ParseUtils.dictionary_int(value_dict, KEY_VALUE)
					)

				var setting := (
						load("uid://cummjubuua6yk").instantiate()
						as ItemIntNode
				)
				setting.item = ItemInt.new()
				setting.item.value = default_value
				setting.item.text = value_text
				_item_keys[setting.item] = key_string
				setting.item.value_changed.connect(_on_setting_changed)
				setting_node = setting
			"float":
				var default_value: float
				if ParseUtils.dictionary_has_number(value_dict, KEY_VALUE):
					default_value = (
							ParseUtils.dictionary_float(value_dict, KEY_VALUE)
					)

				var setting := (
						load("uid://dd0mqtbyhpwcg").instantiate()
						as ItemFloatNode
				)
				setting.item = ItemFloat.new()
				setting.item.value = default_value
				setting.item.text = value_text
				_item_keys[setting.item] = key_string
				setting.item.value_changed.connect(_on_setting_changed)
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
							load("uid://bh8aukwuigg4e").instantiate()
							as ItemOptionsNode
					)
					setting.item = ItemOptions.new()
					setting.item.selected_index = default_value
					setting.item.options = options
					setting.item.text = value_text
					_item_keys[setting.item] = key_string
					setting.item.value_changed.connect(_on_setting_changed)
					setting_node = setting

		if setting_node == null:
			continue

		_settings_container.add_child(setting_node)

		if minimum_height > 0.0:
			minimum_height += 8
		minimum_height += setting_node.size.y

		_is_empty = false

	custom_minimum_size.y = minimum_height + spacing_bottom


func _connect_signals() -> void:
	if metadata == null:
		return

	if not metadata.state_updated.is_connected(_on_state_updated):
		metadata.state_updated.connect(_on_state_updated)


func _disconnect_signals() -> void:
	if metadata == null:
		return

	if metadata.state_updated.is_connected(_on_state_updated):
		metadata.state_updated.disconnect(_on_state_updated)


func _on_setting_changed(item: PropertyTreeItem) -> void:
	if metadata == null or not _item_keys.has(item):
		return
	var key: String = _item_keys[item]

	var value: Variant = item.get_data()
	if value == null:
		return

	metadata.set_setting(key, value)


func _on_state_updated(_metadata: GameMetadata) -> void:
	_update_settings_list()
