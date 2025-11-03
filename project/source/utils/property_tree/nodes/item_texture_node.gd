@tool
class_name ItemTextureNode
extends PropertyTreeNode
## A [PropertyTreeNode] that displays an [ItemTexture].
## Also displays a button that when pressed,
## prompts the user to select an image on their device.

var item := ItemTexture.new()

var _tween: Tween:
	set(value):
		if _tween != null:
			_tween.stop()
		_tween = value

@onready var _label := %Label as Label
@onready var _texture_rect := %TextureRect as TextureRect
@onready var _feedback_label := %Feedback as Label


func _ready() -> void:
	refresh()
	_feedback_label.text = ""
	item.value_changed.connect(_on_item_value_changed)


func refresh() -> void:
	if not is_node_ready():
		return
	super()

	_texture_rect.texture = item.texture()
	_label.text = item.text


func _item() -> PropertyTreeItem:
	return item


func _give_feedback_success() -> void:
	_give_feedback("Image loaded", Color.GREEN)


func _give_feedback_failure() -> void:
	_give_feedback("Loading failed", Color.RED)


func _give_feedback(text: String, color: Color) -> void:
	_feedback_label.text = text
	_feedback_label.modulate = color
	_feedback_label.modulate.a = 0.0
	_tween = get_tree().create_tween()
	_tween.tween_property(_feedback_label, "modulate:a", 1.0, 0.5)
	_tween.tween_property(
			_feedback_label, "modulate:a", 0.0, 0.5
	).set_delay(2.0)


func _on_item_value_changed(_input_item: PropertyTreeItem) -> void:
	_texture_rect.texture = item.texture()


func _on_file_dialog_file_selected(path: String) -> void:
	var new_texture := TextureFromFilePath.new(
			path, item.project_textures.project_absolute_path_ref()
	)
	if new_texture.texture(item.project_textures) == null:
		_give_feedback_failure()
	else:
		item.value = new_texture
		_give_feedback_success()
