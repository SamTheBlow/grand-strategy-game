@tool
class_name ItemTextureNode
extends PropertyTreeNode
## A [PropertyTreeNode] that displays an [ItemTexture].
## Also displays a button that when pressed,
## prompts the user to select an image on their device.

var item := ItemTexture.new()

@onready var _label := %Label as Label
@onready var _texture_rect := %TextureRect as TextureRect
@onready var _error_message := %ErrorMessage as Label


func _ready() -> void:
	refresh()
	_error_message.text = ""
	item.value_changed.connect(_on_item_value_changed)


func refresh() -> void:
	if not is_node_ready():
		return
	super()

	_texture_rect.texture = item.value
	_label.text = item.text


func _item() -> PropertyTreeItem:
	return item


func _on_item_value_changed(_input_item: PropertyTreeItem) -> void:
	_texture_rect.texture = item.value


func _on_browse_button_pressed() -> void:
	pass # TODO open file browsing
