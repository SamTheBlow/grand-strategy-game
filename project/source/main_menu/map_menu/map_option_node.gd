class_name MapOptionNode
extends Control
## Shows a map for the user to select in the map selection menu.


signal selected(id: int)

@export var color_normal: Color
@export var color_selected: Color

@export var is_file_path_visible: bool = true:
	set(value):
		is_file_path_visible = value
		_update_file_path_visibility()

var map_metadata := MapMetadata.new():
	set(value):
		map_metadata = value
		_update_info()

var id: int = -1
var _is_selected: bool = false

@onready var _background_color := %BackgroundColor as ColorRect
@onready var _icon_texture := %IconTexture as TextureRect
@onready var _name_label := %NameLabel as Label
@onready var _file_path_node := %FilePathNode as Control
@onready var _file_path_label := %FilePathLabel as Label


func _ready() -> void:
	_update_info()
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


func _update_background_color() -> void:
	_background_color.color = color_selected if _is_selected else color_normal


func _update_file_path_visibility() -> void:
	if _file_path_node != null:
		_file_path_node.visible = is_file_path_visible


func _update_info() -> void:
	if not is_node_ready():
		return
	
	_icon_texture.texture = map_metadata.icon
	_name_label.text = map_metadata.map_name
	_file_path_label.text = map_metadata.file_path


func _on_button_pressed() -> void:
	selected.emit(id)
