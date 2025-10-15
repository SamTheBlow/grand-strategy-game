class_name InterfaceWorldDecorationEdit
extends AppEditorInterface
## The interface in which the user can edit given [WorldDecoration].

signal back_pressed()
signal delete_pressed(world_decoration: WorldDecoration)
signal duplicate_pressed(world_decoration: WorldDecoration)

var world_decoration := WorldDecoration.new()

@onready var _preview_rect := %PreviewRect as TextureRect
@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_settings.refresh()

	_load_settings()
	_update_preview()

	# Texture
	#(_settings.item.child_items[0] as ItemTexture).value_changed.connect(
	#		_on_texture_value_changed
	#)
	# Flip H
	(_settings.item.child_items[1] as ItemBool).value_changed.connect(
			_on_flip_h_value_changed
	)
	# Flip V
	(_settings.item.child_items[2] as ItemBool).value_changed.connect(
			_on_flip_v_value_changed
	)
	# Position
	(_settings.item.child_items[3] as ItemVector2).value_changed.connect(
			_on_position_value_changed
	)
	# Rotation
	(_settings.item.child_items[4] as ItemFloat).value_changed.connect(
			_on_rotation_value_changed
	)
	# Scale
	(_settings.item.child_items[5] as ItemVector2).value_changed.connect(
			_on_scale_value_changed
	)
	# Color
	(_settings.item.child_items[6] as ItemColor).value_changed.connect(
			_on_color_value_changed
	)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"delete"):
		delete_pressed.emit(world_decoration)
	if Input.is_action_just_pressed(&"duplicate"):
		duplicate_pressed.emit(world_decoration)


func _load_settings() -> void:
	#(_settings.item.child_items[0] as ItemTexture).value = (
	#		world_decoration.texture
	#)
	(_settings.item.child_items[1] as ItemBool).value = (
			world_decoration.flip_h
	)
	(_settings.item.child_items[2] as ItemBool).value = (
			world_decoration.flip_v
	)
	(_settings.item.child_items[3] as ItemVector2).set_data(
			world_decoration.position
	)
	(_settings.item.child_items[4] as ItemFloat).value = (
			world_decoration.rotation_degrees
	)
	(_settings.item.child_items[5] as ItemVector2).set_data(
			world_decoration.scale
	)
	(_settings.item.child_items[6] as ItemColor).value = (
			world_decoration.color
	)


func _update_preview() -> void:
	world_decoration.apply_preview(_preview_rect)


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(world_decoration)


#func _on_texture_value_changed(item: ItemTexture2D) -> void:
#	world_decoration.texture = item.value
#	_update_preview()


func _on_flip_h_value_changed(item: ItemBool) -> void:
	world_decoration.flip_h = item.value
	_update_preview()


func _on_flip_v_value_changed(item: ItemBool) -> void:
	world_decoration.flip_v = item.value
	_update_preview()


func _on_position_value_changed(item: ItemVector2) -> void:
	world_decoration.position = item.get_data()
	_update_preview()


func _on_rotation_value_changed(item: ItemFloat) -> void:
	world_decoration.rotation_degrees = item.value
	_update_preview()


func _on_scale_value_changed(item: ItemVector2) -> void:
	world_decoration.scale = item.get_data()
	_update_preview()


func _on_color_value_changed(item: ItemColor) -> void:
	world_decoration.color = item.value
	_update_preview()
