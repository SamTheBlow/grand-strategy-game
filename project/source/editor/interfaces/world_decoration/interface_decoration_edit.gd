class_name InterfaceWorldDecorationEdit
extends AppEditorInterface
## The interface in which the user can edit given [WorldDecoration].

var world_decoration: WorldDecoration


func _ready() -> void:
	var preview_rect := %PreviewRect as TextureRect
	_apply_preview(preview_rect)
	world_decoration.changed.connect(
			_apply_preview.bind(preview_rect).unbind(1)
	)

	_setup_settings(%Settings as ItemVoidNode)

	project.game.world.decorations.removed.connect(
			_on_world_decoration_removed
	)

	closed.connect(navigator.open_new_interface.bind(
			InterfaceNavigator.Type.DECORATION_LIST
	))


func _load_settings(settings_item: PropertyTreeItem) -> void:
	# Texture
	var item_texture := settings_item.child_items[0] as ItemTexture
	item_texture.fallback_texture = WorldDecoration.DEFAULT_TEXTURE
	item_texture.value = world_decoration.texture
	item_texture.value_changed.connect(_on_texture_value_changed)
	item_texture.popup_requested.connect(
			texture_popup_requested.emit.bind(project.textures)
	)
	world_decoration.texture_changed.connect(
			_on_texture_changed.bind(item_texture)
	)

	# Flip H
	var item_flip_h := settings_item.child_items[1] as ItemBool
	item_flip_h.value = world_decoration.flip_h
	item_flip_h.value_changed.connect(_on_flip_h_value_changed)
	world_decoration.flip_h_changed.connect(
			_on_flip_h_changed.bind(item_flip_h)
	)

	# Flip V
	var item_flip_v := settings_item.child_items[2] as ItemBool
	item_flip_v.value = world_decoration.flip_v
	item_flip_v.value_changed.connect(_on_flip_v_value_changed)
	world_decoration.flip_v_changed.connect(
			_on_flip_v_changed.bind(item_flip_v)
	)

	# Position
	var item_position := settings_item.child_items[3] as ItemVector2
	item_position.set_data(world_decoration.position)
	item_position.value_changed.connect(_on_position_value_changed)
	world_decoration.position_changed.connect(
			_on_position_changed.bind(item_position)
	)

	# Rotation
	var item_rotation := settings_item.child_items[4] as ItemFloat
	item_rotation.value = world_decoration.rotation_degrees
	item_rotation.value_changed.connect(_on_rotation_value_changed)
	world_decoration.rotation_changed.connect(
			_on_rotation_changed.bind(item_rotation)
	)

	# Scale
	var item_scale := settings_item.child_items[5] as ItemVector2
	item_scale.set_data(world_decoration.scale)
	item_scale.value_changed.connect(_on_scale_value_changed)
	world_decoration.scale_changed.connect(
			_on_scale_changed.bind(item_scale)
	)

	# Color
	var item_color := settings_item.child_items[6] as ItemColor
	item_color.value = world_decoration.color
	item_color.value_changed.connect(_on_color_value_changed)
	world_decoration.color_changed.connect(
			_on_color_changed.bind(item_color)
	)


func _delete() -> void:
	_apply_undo_redo_method(
			"Delete world decoration",
			project.game.world.decorations.remove.bind(world_decoration),
			project.game.world.decorations.add.bind(world_decoration)
	)


func _duplicate() -> void:
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
	_apply_undo_redo_method(
			"Duplicate world decoration",
			project.game.world.decorations.add.bind(new_decoration),
			project.game.world.decorations.remove.bind(new_decoration)
	)

	# Select the new decoration for editing
	decoration_select_requested.emit(new_decoration)


func _apply_preview(preview_rect: TextureRect) -> void:
	world_decoration.apply_preview(preview_rect)


func _on_world_decoration_removed(decoration_removed: WorldDecoration) -> void:
	if decoration_removed == world_decoration:
		closed.emit()


func _on_texture_value_changed(item: ItemTexture) -> void:
	_apply_undo_redo_property(
			"Change world decoration's texture",
			world_decoration,
			&"texture",
			world_decoration.texture,
			item.value
	)


func _on_flip_h_value_changed(item: ItemBool) -> void:
	_apply_undo_redo_property(
			"Change world decoration's horizontal flip",
			world_decoration,
			&"flip_h",
			world_decoration.flip_h,
			item.value
	)


func _on_flip_v_value_changed(item: ItemBool) -> void:
	_apply_undo_redo_property(
			"Change world decoration's vertical flip",
			world_decoration,
			&"flip_v",
			world_decoration.flip_v,
			item.value
	)


func _on_position_value_changed(item: ItemVector2) -> void:
	_apply_undo_redo_property(
			"Change world decoration's position",
			world_decoration,
			&"position",
			world_decoration.position,
			item.get_data()
	)


func _on_rotation_value_changed(item: ItemFloat) -> void:
	_apply_undo_redo_property(
			"Change world decoration's rotation",
			world_decoration,
			&"rotation_degrees",
			world_decoration.rotation_degrees,
			item.value
	)


func _on_scale_value_changed(item: ItemVector2) -> void:
	_apply_undo_redo_property(
			"Change world decoration's scale",
			world_decoration,
			&"scale",
			world_decoration.scale,
			item.get_data()
	)


func _on_color_value_changed(item: ItemColor) -> void:
	_apply_undo_redo_property(
			"Change world decoration's color",
			world_decoration,
			&"color",
			world_decoration.color,
			item.value
	)


func _on_texture_changed(item: ItemTexture) -> void:
	_set_setting_no_signal(
			item, _on_texture_value_changed, world_decoration.texture
	)


func _on_flip_h_changed(item: ItemBool) -> void:
	_set_setting_no_signal(
			item, _on_flip_h_value_changed, world_decoration.flip_h
	)


func _on_flip_v_changed(item: ItemBool) -> void:
	_set_setting_no_signal(
			item, _on_flip_v_value_changed, world_decoration.flip_v
	)


func _on_position_changed(item: ItemVector2) -> void:
	_set_setting_no_signal(
			item, _on_position_value_changed, world_decoration.position
	)


func _on_rotation_changed(item: ItemFloat) -> void:
	_set_setting_no_signal(
			item, _on_rotation_value_changed, world_decoration.rotation_degrees
	)


func _on_scale_changed(item: ItemVector2) -> void:
	_set_setting_no_signal(
			item, _on_scale_value_changed, world_decoration.scale
	)


func _on_color_changed(item: ItemColor) -> void:
	_set_setting_no_signal(
			item, _on_color_value_changed, world_decoration.color
	)
