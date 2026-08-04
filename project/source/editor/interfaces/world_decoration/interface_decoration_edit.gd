class_name InterfaceWorldDecorationEdit
extends AppEditorInterface
## The interface in which the user can edit given [WorldDecoration].

var world_decoration: WorldDecoration

@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	var preview_rect := %PreviewRect as TextureRect
	_apply_preview(preview_rect)
	world_decoration.changed.connect(
			_apply_preview.bind(preview_rect).unbind(1)
	)

	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_load_settings()
	_settings.refresh()

	project.game.world.decorations.removed.connect(
			_on_world_decoration_removed
	)

	closed.connect(navigator.open_new_interface.bind(
			InterfaceNavigator.InterfaceType.DECORATION_LIST,
			project,
			editor_settings
	))


func _unhandled_input(event: InputEvent) -> void:
	super(event)

	if event.is_action_pressed(&"delete"):
		_delete_decoration()
	if event.is_action_pressed(&"duplicate"):
		_duplicate_decoration()


func _load_settings() -> void:
	# Texture
	var item_texture := _settings.item.child_items[0] as ItemTexture
	item_texture.fallback_texture = WorldDecoration.DEFAULT_TEXTURE
	item_texture.value = world_decoration.texture
	item_texture.value_changed.connect(_on_texture_value_changed)
	item_texture.popup_requested.connect(
			texture_popup_requested.emit.bind(project.textures)
	)
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


func _delete_decoration() -> void:
	undo_redo.create_action("Delete world decoration")
	undo_redo.add_do_method(
			project.game.world.decorations.remove.bind(world_decoration)
	)
	undo_redo.add_undo_method(
			project.game.world.decorations.add.bind(world_decoration)
	)
	undo_redo.commit_action()


func _duplicate_decoration() -> void:
	const _DUPLICATE_DECORATION_OFFSET = Vector2(64.0, 64.0)

	# Create duplicate
	var new_decoration := WorldDecoration.new()
	new_decoration.texture = world_decoration.texture
	new_decoration.flip_h = world_decoration.flip_h
	new_decoration.flip_v = world_decoration.flip_v
	new_decoration.position = (
			world_decoration.position + _DUPLICATE_DECORATION_OFFSET
	)
	new_decoration.rotation_degrees = world_decoration.rotation_degrees
	new_decoration.scale = world_decoration.scale
	new_decoration.color = world_decoration.color

	# Create and apply undo_redo action
	undo_redo.create_action("Duplicate world decoration")
	undo_redo.add_do_method(
			project.game.world.decorations.add.bind(new_decoration)
	)
	undo_redo.add_undo_method(
			project.game.world.decorations.remove.bind(new_decoration)
	)
	undo_redo.commit_action()

	# Open interface to edit the new decoration
	navigator.open_decoration_edit_interface(
			new_decoration, project, editor_settings
	)


func _apply_preview(preview_rect: TextureRect) -> void:
	world_decoration.apply_preview(preview_rect)


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


func _on_world_decoration_removed(decoration_removed: WorldDecoration) -> void:
	if decoration_removed == world_decoration:
		closed.emit()


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
