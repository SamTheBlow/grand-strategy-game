class_name InterfaceWorldDecorationEdit
extends AppEditorInterface
## The interface in which the user can edit given [WorldDecoration].

signal closed()
signal delete_pressed(world_decoration: WorldDecoration)
signal duplicate_pressed(world_decoration: WorldDecoration)
signal texture_popup_requested(item_texture: ItemTexture)

var world_decoration: WorldDecoration:
	set(value):
		if world_decoration != null:
			world_decoration.changed.disconnect(_refresh_preview)

		world_decoration = value

		_refresh_preview()
		world_decoration.changed.connect(_refresh_preview)

var project_textures: ProjectTextures

## This interface automatically closes
## if its decoration is removed from this decorations list.
## May be null, in which case this feature is not used.
var world_decorations: WorldDecorations = null:
	set(value):
		if world_decorations != null:
			world_decorations.removed.disconnect(
					_on_world_decoration_removed
			)

		world_decorations = value

		if world_decorations != null:
			world_decorations.removed.connect(
					_on_world_decoration_removed
			)

@onready var _preview_rect := %PreviewRect as TextureRect
@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	# This is just so that this node still works by itself in the Godot editor
	if world_decoration == null:
		world_decoration = WorldDecoration.new()

	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_settings.refresh()

	_load_settings()
	_refresh_preview()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"delete"):
		delete_pressed.emit(world_decoration)
	if Input.is_action_just_pressed(&"duplicate"):
		duplicate_pressed.emit(world_decoration)


func _load_settings() -> void:
	# Texture
	var item_texture := _settings.item.child_items[0] as ItemTexture
	item_texture.project_textures = project_textures
	item_texture.fallback_texture = WorldDecoration.DEFAULT_TEXTURE
	item_texture.value = world_decoration.texture
	item_texture.value_changed.connect(_on_texture_value_changed)
	item_texture.popup_requested.connect(texture_popup_requested.emit)
	# Flip H
	(_settings.item.child_items[1] as ItemBool).value = (
			world_decoration.flip_h
	)
	(_settings.item.child_items[1] as ItemBool).value_changed.connect(
			_on_flip_h_value_changed
	)
	# Flip V
	(_settings.item.child_items[2] as ItemBool).value = (
			world_decoration.flip_v
	)
	(_settings.item.child_items[2] as ItemBool).value_changed.connect(
			_on_flip_v_value_changed
	)
	# Position
	(_settings.item.child_items[3] as ItemVector2).set_data(
			world_decoration.position
	)
	(_settings.item.child_items[3] as ItemVector2).value_changed.connect(
			_on_position_value_changed
	)
	# Rotation
	(_settings.item.child_items[4] as ItemFloat).value = (
			world_decoration.rotation_degrees
	)
	(_settings.item.child_items[4] as ItemFloat).value_changed.connect(
			_on_rotation_value_changed
	)
	# Scale
	(_settings.item.child_items[5] as ItemVector2).set_data(
			world_decoration.scale
	)
	(_settings.item.child_items[5] as ItemVector2).value_changed.connect(
			_on_scale_value_changed
	)
	# Color
	(_settings.item.child_items[6] as ItemColor).value = (
			world_decoration.color
	)
	(_settings.item.child_items[6] as ItemColor).value_changed.connect(
			_on_color_value_changed
	)


func _refresh_preview(_world_decoration: WorldDecoration = null) -> void:
	if not is_node_ready():
		return
	world_decoration.apply_preview(_preview_rect, project_textures)


func _apply_undo_redo_action(
		description: String,
		property_name: StringName,
		old_value: Variant,
		new_value: Variant
) -> void:
	undo_redo.create_action(description)
	undo_redo.add_do_property(world_decoration, property_name, new_value)
	undo_redo.add_undo_property(world_decoration, property_name, old_value)
	undo_redo.commit_action()


func _on_back_button_pressed() -> void:
	closed.emit()


func _on_world_decoration_removed(
		world_decoration_removed: WorldDecoration
) -> void:
	if world_decoration_removed == world_decoration:
		closed.emit()


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(world_decoration)


func _on_texture_value_changed(item: ItemTexture) -> void:
	_apply_undo_redo_action(
			"Change world decoration's texture",
			&"texture",
			world_decoration.texture,
			item.value
	)


func _on_flip_h_value_changed(item: ItemBool) -> void:
	_apply_undo_redo_action(
			"Change world decoration's horizontal flip",
			&"flip_h",
			world_decoration.flip_h,
			item.value
	)


func _on_flip_v_value_changed(item: ItemBool) -> void:
	_apply_undo_redo_action(
			"Change world decoration's vertical flip",
			&"flip_v",
			world_decoration.flip_v,
			item.value
	)


func _on_position_value_changed(item: ItemVector2) -> void:
	_apply_undo_redo_action(
			"Change world decoration's position",
			&"position",
			world_decoration.position,
			item.get_data()
	)


func _on_rotation_value_changed(item: ItemFloat) -> void:
	_apply_undo_redo_action(
			"Change world decoration's rotation",
			&"rotation_degrees",
			world_decoration.rotation_degrees,
			item.value
	)


func _on_scale_value_changed(item: ItemVector2) -> void:
	_apply_undo_redo_action(
			"Change world decoration's scale",
			&"scale",
			world_decoration.scale,
			item.get_data()
	)


func _on_color_value_changed(item: ItemColor) -> void:
	_apply_undo_redo_action(
			"Change world decoration's color",
			&"color",
			world_decoration.color,
			item.value
	)
