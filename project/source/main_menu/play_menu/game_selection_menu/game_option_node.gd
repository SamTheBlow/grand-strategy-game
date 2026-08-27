class_name GameOptionNode
extends Control
## Shows a game for the user to select in the [GameSelectionMenu].

signal selected(this: GameOptionNode)

## If set to false, the file path will stay hidden no matter what.
var is_file_path_visible: bool = true:
	set(value):
		is_file_path_visible = value
		_refresh_file_path_visibility()

var meta_bundle := MetadataBundle.new():
	set(value):
		meta_bundle = value
		_refresh_info()
		_refresh_file_path_visibility()

var id: int = -1

@onready var _button := %Button as Button
@onready var _icon_texture := %IconTexture as TextureRect
@onready var _name_label := %NameLabel as Label
@onready var _file_path_node := %FilePathNode as Control
@onready var _file_path_label := %FilePathLabel as Label


func _ready() -> void:
	_refresh_info()
	_refresh_file_path_visibility()


func select() -> void:
	_button.button_pressed = true


func deselect() -> void:
	_button.button_pressed = false


func _refresh_info() -> void:
	if not is_node_ready():
		return

	_icon_texture.texture = meta_bundle.metadata.icon_texture()
	_name_label.text = meta_bundle.metadata.project_name_or_default()
	_file_path_label.text = meta_bundle.project_absolute_path


func _refresh_file_path_visibility() -> void:
	if _file_path_node == null:
		return

	_file_path_node.visible = (
			is_file_path_visible and meta_bundle.project_absolute_path != ""
	)


func _on_button_pressed() -> void:
	selected.emit(self)
