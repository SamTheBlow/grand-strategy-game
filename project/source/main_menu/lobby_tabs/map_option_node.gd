class_name MapOptionNode
extends Control
## Shows a map for the user to select in the map selection menu.


signal selected(id: int)

@export var file_path: String
@export var color_normal: Color
@export var color_selected: Color

@export var is_file_path_visible: bool = true:
	set(value):
		is_file_path_visible = value
		_update_file_path_visibility()

var id: int = -1
var _is_selected: bool = false

@onready var _background_color := %BackgroundColor as ColorRect
@onready var _icon_texture := %IconTexture as TextureRect
@onready var _name_label := %NameLabel as Label
@onready var _file_path_node := %FilePathNode as Control
@onready var _file_path_label := %FilePathLabel as Label


func _ready() -> void:
	_file_path_label.text = file_path
	_load_metadata()
	_update_background_color()
	_update_file_path_visibility()


## Adds highlight to this item.
func select() -> void:
	if _is_selected:
		return
	
	_is_selected = true
	_update_background_color()


## Removes highlight from this item.
func deselect() -> void:
	if not _is_selected:
		return
	
	_is_selected = false
	_update_background_color()


func _load_metadata() -> void:
	const KEY_METADATA: String = "meta"
	const KEY_META_NAME: String = "name"
	const KEY_META_ICON: String = "icon"
	
	var file_json := FileJSON.new()
	file_json.load_json(file_path)
	if file_json.error:
		#print_debug("Failed to load map JSON: ", file_json.error_message)
		return
	var json_data: Variant = file_json.result
	if json_data is not Dictionary:
		#print_debug("Can't load map metadata: JSON data is not a Dictionary")
		return
	var json_dict := json_data as Dictionary
	if not ParseUtils.dictionary_has_dictionary(json_dict, KEY_METADATA):
		return
	var meta_dict := json_dict[KEY_METADATA] as Dictionary
	
	if ParseUtils.dictionary_has_string(meta_dict, KEY_META_NAME):
		var map_name: String = meta_dict[KEY_META_NAME]
		_name_label.text = map_name
	else:
		_name_label.text = "(No name)"
	
	if ParseUtils.dictionary_has_string(meta_dict, KEY_META_ICON):
		var map_icon_file_path: String = meta_dict[KEY_META_ICON]
		_load_map_icon(map_icon_file_path)


func _load_map_icon(icon_file_path: String) -> void:
	if icon_file_path.is_absolute_path():
		push_error(
			"Metadata for map icon uses an absolute file path. ",
			"Only relative file paths are allowed. ",
			"Please make sure the icon's file path is relative to the map's."
		)
		return
	
	var map_dir: DirAccess = DirAccess.open(file_path.get_base_dir())
	if not map_dir.file_exists(icon_file_path):
		push_error("File for map icon does not exist.")
		return
	
	map_dir.change_dir(icon_file_path.get_base_dir())
	var true_icon_path: String = (
			map_dir.get_current_dir().path_join(icon_file_path.get_file())
	)
	#print_debug("Loading icon: ", true_icon_path)
	
	# I'm not sure if this works in 100% of cases but it seems good enough
	if true_icon_path.begins_with("res://"):
		# This is most likely an already imported texture, so load it normally
		_icon_texture.texture = load(true_icon_path) as Texture2D
	else:
		# And here we use this method to load images that aren't yet imported
		_icon_texture.texture = ImageTexture.create_from_image(
				Image.load_from_file(true_icon_path)
		)


func _update_background_color() -> void:
	_background_color.color = color_selected if _is_selected else color_normal


func _update_file_path_visibility() -> void:
	if _file_path_node != null:
		_file_path_node.visible = is_file_path_visible


func _on_button_pressed() -> void:
	selected.emit(id)
