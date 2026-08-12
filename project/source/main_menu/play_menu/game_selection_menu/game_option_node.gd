class_name GameOptionNode
extends Control
## Shows a game for the user to select in the [GameSelectionMenu].

signal selected(this: GameOptionNode)

@export var color_normal: Color
@export var color_selected: Color

## If set to false, the file path will stay hidden no matter what.
var is_file_path_visible: bool = true:
	set(value):
		is_file_path_visible = value
		_update_file_path_visibility()

var meta_bundle := MetadataBundle.new():
	set(value):
		meta_bundle = value
		_update_info()
		_update_file_path_visibility()

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


func select() -> void:
	if _is_selected:
		return

	_is_selected = true
	_update_background_color()


func deselect() -> void:
	if not _is_selected:
		return

	_is_selected = false
	_update_background_color()


func _update_background_color() -> void:
	_background_color.color = color_selected if _is_selected else color_normal


func _update_file_path_visibility() -> void:
	if _file_path_node == null:
		return

	_file_path_node.visible = (
			is_file_path_visible and meta_bundle.project_absolute_path != ""
	)


func _update_info() -> void:
	if not is_node_ready():
		return

	_icon_texture.texture = meta_bundle.metadata.icon_texture()
	_name_label.text = meta_bundle.metadata.project_name_or_default()
	_file_path_label.text = meta_bundle.project_absolute_path


func _on_button_pressed() -> void:
	selected.emit(self)
