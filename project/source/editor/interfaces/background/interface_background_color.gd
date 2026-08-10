class_name InterfaceBackgroundColor
extends AppEditorInterface


func _ready() -> void:
	var item := (
			(%GameSettingsCategory as ItemVoidNode).item.child_items[0]
			as ItemColor
	)
	item.value = project.game.world.background_color
	item.value_changed.connect(_on_item_value_changed)
	project.game.world.background_color_changed.connect(
			_on_internal_value_changed.bind(item)
	)

	closed.connect(navigator.close_interface)


func _on_item_value_changed(new_value: Color) -> void:
	_apply_undo_redo_property(
			"Change background color",
			project.game.world,
			&"background_color",
			project.game.world.background_color,
			new_value
	)


func _on_internal_value_changed(color: Color, item: ItemColor) -> void:
	_set_setting_no_signal(item, _on_item_value_changed, color)
