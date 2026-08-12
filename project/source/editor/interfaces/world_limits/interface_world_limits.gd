class_name InterfaceWorldLimits
extends AppEditorInterface


func _ready() -> void:
	var world_limits: WorldLimits = project.game.world.limits()

	var item_mode := ItemBool.new()
	item_mode.text = "Custom world limits"
	item_mode.value = world_limits.is_custom_limits_enabled()
	item_mode.value_changed.connect(_on_item_mode_changed)

	var is_disabled: bool = not world_limits.is_custom_limits_enabled()

	var item_left := ItemInt.new()
	item_left.text = "Left"
	item_left.value = world_limits.limit_left()
	item_left.is_disabled = is_disabled
	item_left.value_changed.connect(_on_item_left_changed)

	var item_top := ItemInt.new()
	item_top.text = "Top"
	item_top.value = world_limits.limit_top()
	item_top.is_disabled = is_disabled
	item_top.value_changed.connect(_on_item_top_changed)

	var item_right := ItemInt.new()
	item_right.text = "Right"
	item_right.value = world_limits.limit_right()
	item_right.is_disabled = is_disabled
	item_right.value_changed.connect(_on_item_right_changed)

	var item_bottom := ItemInt.new()
	item_bottom.text = "Bottom"
	item_bottom.value = world_limits.limit_bottom()
	item_bottom.is_disabled = is_disabled
	item_bottom.value_changed.connect(_on_item_bottom_changed)

	world_limits.mode_changed.connect(_on_custom_limits_toggled.bind(
			item_mode, item_left, item_top, item_right, item_bottom
	))
	world_limits.current_limits_changed.connect(_on_limits_changed.bind(
			item_left, item_top, item_right, item_bottom
	))

	# Setup editor settings
	var editor_settings_node := %EditorSettingsCategory as ItemVoidNode
	editor_settings_node.item.child_items = [
		editor_settings.show_world_limits
	]
	editor_settings_node.refresh()

	# Setup game settings
	var game_settings_node := %GameSettingsCategory as ItemVoidNode
	game_settings_node.item.child_items = [
		item_mode, item_left, item_right, item_top, item_bottom
	]
	game_settings_node.refresh()

	closed.connect(navigator.close_interface)


func _on_item_mode_changed(new_value: bool) -> void:
	var limits: WorldLimits = project.game.world.limits()
	if new_value:
		_apply_undo_redo_method(
				"Enable custom world limits",
				limits.enable_custom_limits,
				limits.disable_custom_limits
		)
	else:
		_apply_undo_redo_method(
				"Disable custom world limits",
				limits.disable_custom_limits,
				limits.enable_custom_limits
		)


func _on_item_left_changed(new_value: int) -> void:
	var limits: WorldLimits = project.game.world.limits()
	_apply_undo_redo_method(
			"Set custom world limits, left side",
			limits.set_custom_limit_left.bind(new_value),
			limits.set_custom_limit_left.bind(limits.custom_limits.x)
	)


func _on_item_top_changed(new_value: int) -> void:
	var limits: WorldLimits = project.game.world.limits()
	_apply_undo_redo_method(
			"Set custom world limits, top side",
			limits.set_custom_limit_top.bind(new_value),
			limits.set_custom_limit_top.bind(limits.custom_limits.y)
	)


func _on_item_right_changed(new_value: int) -> void:
	var limits: WorldLimits = project.game.world.limits()
	_apply_undo_redo_method(
			"Set custom world limits, right side",
			limits.set_custom_limit_right.bind(new_value),
			limits.set_custom_limit_right.bind(limits.custom_limits.z)
	)


func _on_item_bottom_changed(new_value: int) -> void:
	var limits: WorldLimits = project.game.world.limits()
	_apply_undo_redo_method(
			"Set custom world limits, bottom side",
			limits.set_custom_limit_bottom.bind(new_value),
			limits.set_custom_limit_bottom.bind(limits.custom_limits.w)
	)


func _on_custom_limits_toggled(
		item_custom_limits_enabled: ItemBool,
		item_left: ItemInt,
		item_top: ItemInt,
		item_right: ItemInt,
		item_bottom: ItemInt
) -> void:
	var world_limits: WorldLimits = project.game.world.limits()

	_set_setting_no_signal(
			item_custom_limits_enabled,
			_on_item_mode_changed,
			world_limits.is_custom_limits_enabled()
	)

	var is_disabled: bool = not world_limits.is_custom_limits_enabled()
	item_left.is_disabled = is_disabled
	item_top.is_disabled = is_disabled
	item_right.is_disabled = is_disabled
	item_bottom.is_disabled = is_disabled


func _on_limits_changed(
		item_left: ItemInt,
		item_top: ItemInt,
		item_right: ItemInt,
		item_bottom: ItemInt
) -> void:
	var limits: WorldLimits = project.game.world.limits()
	_set_setting_no_signal(
			item_left, _on_item_left_changed, limits.limit_left()
	)
	_set_setting_no_signal(
			item_top, _on_item_top_changed, limits.limit_top()
	)
	_set_setting_no_signal(
			item_right, _on_item_right_changed, limits.limit_right()
	)
	_set_setting_no_signal(
			item_bottom, _on_item_bottom_changed, limits.limit_bottom()
	)
