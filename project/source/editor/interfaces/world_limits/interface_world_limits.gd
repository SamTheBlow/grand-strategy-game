class_name InterfaceWorldLimits
extends AppEditorInterface

var world_limits: WorldLimits

var _item_custom_limits_enabled := ItemBool.new()
var _item_world_limit_left := ItemInt.new()
var _item_world_limit_right := ItemInt.new()
var _item_world_limit_top := ItemInt.new()
var _item_world_limit_bottom := ItemInt.new()

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode


func _ready() -> void:
	_item_custom_limits_enabled.text = "Custom world limits"
	_item_custom_limits_enabled.value = world_limits.is_custom_limits_enabled()
	_item_custom_limits_enabled.value_changed.connect(_on_item_mode_changed)
	world_limits.mode_changed.connect(_on_custom_limits_toggled)

	var is_disabled: bool = not world_limits.is_custom_limits_enabled()
	_item_world_limit_left.text = "Left"
	_item_world_limit_left.value = world_limits.limit_left()
	_item_world_limit_left.is_disabled = is_disabled
	_item_world_limit_left.value_changed.connect(_on_item_left_changed)
	_item_world_limit_right.text = "Right"
	_item_world_limit_right.value = world_limits.limit_right()
	_item_world_limit_right.is_disabled = is_disabled
	_item_world_limit_right.value_changed.connect(_on_item_right_changed)
	_item_world_limit_top.text = "Top"
	_item_world_limit_top.value = world_limits.limit_top()
	_item_world_limit_top.is_disabled = is_disabled
	_item_world_limit_top.value_changed.connect(_on_item_top_changed)
	_item_world_limit_bottom.text = "Bottom"
	_item_world_limit_bottom.value = world_limits.limit_bottom()
	_item_world_limit_bottom.is_disabled = is_disabled
	_item_world_limit_bottom.value_changed.connect(_on_item_bottom_changed)
	world_limits.current_limits_changed.connect(_on_limits_changed)

	# Setup editor settings
	_editor_settings_node.item.child_items = [
		editor_settings.show_world_limits
	]
	_editor_settings_node.refresh()

	# Setup game settings
	_game_settings_node.item.child_items = [
		_item_custom_limits_enabled,
		_item_world_limit_left,
		_item_world_limit_right,
		_item_world_limit_top,
		_item_world_limit_bottom,
	]
	_game_settings_node.refresh()


func _on_item_mode_changed(_item: PropertyTreeItem) -> void:
	if _item_custom_limits_enabled.value:
		undo_redo.create_action("Enable custom world limits")
		undo_redo.add_do_method(world_limits.enable_custom_limits)
		undo_redo.add_undo_method(world_limits.disable_custom_limits)
		undo_redo.commit_action()
	else:
		undo_redo.create_action("Disable custom world limits")
		undo_redo.add_do_method(world_limits.disable_custom_limits)
		undo_redo.add_undo_method(world_limits.enable_custom_limits)
		undo_redo.commit_action()


func _on_item_left_changed(_item: PropertyTreeItem) -> void:
	undo_redo.create_action("Set custom world limits, left side")
	undo_redo.add_do_method(world_limits.set_custom_limit_left.bind(
			_item_world_limit_left.value
	))
	undo_redo.add_undo_method(world_limits.set_custom_limit_left.bind(
			world_limits.custom_limits.x
	))
	undo_redo.commit_action()


func _on_item_right_changed(_item: PropertyTreeItem) -> void:
	undo_redo.create_action("Set custom world limits, right side")
	undo_redo.add_do_method(world_limits.set_custom_limit_right.bind(
			_item_world_limit_right.value
	))
	undo_redo.add_undo_method(world_limits.set_custom_limit_right.bind(
			world_limits.custom_limits.z
	))
	undo_redo.commit_action()


func _on_item_top_changed(_item: PropertyTreeItem) -> void:
	undo_redo.create_action("Set custom world limits, top side")
	undo_redo.add_do_method(world_limits.set_custom_limit_top.bind(
			_item_world_limit_top.value
	))
	undo_redo.add_undo_method(world_limits.set_custom_limit_top.bind(
			world_limits.custom_limits.y
	))
	undo_redo.commit_action()


func _on_item_bottom_changed(_item: PropertyTreeItem) -> void:
	undo_redo.create_action("Set custom world limits, bottom side")
	undo_redo.add_do_method(world_limits.set_custom_limit_bottom.bind(
			_item_world_limit_bottom.value
	))
	undo_redo.add_undo_method(world_limits.set_custom_limit_bottom.bind(
			world_limits.custom_limits.w
	))
	undo_redo.commit_action()


func _on_custom_limits_toggled() -> void:
	_item_custom_limits_enabled.value_changed.disconnect(_on_item_mode_changed)
	_item_custom_limits_enabled.value = world_limits.is_custom_limits_enabled()
	_item_custom_limits_enabled.value_changed.connect(_on_item_mode_changed)

	var is_disabled: bool = not world_limits.is_custom_limits_enabled()
	_item_world_limit_left.is_disabled = is_disabled
	_item_world_limit_top.is_disabled = is_disabled
	_item_world_limit_right.is_disabled = is_disabled
	_item_world_limit_bottom.is_disabled = is_disabled


func _on_limits_changed(_limits: WorldLimits = null) -> void:
	_item_world_limit_left.value_changed.disconnect(_on_item_left_changed)
	_item_world_limit_right.value_changed.disconnect(_on_item_right_changed)
	_item_world_limit_top.value_changed.disconnect(_on_item_top_changed)
	_item_world_limit_bottom.value_changed.disconnect(_on_item_bottom_changed)

	_item_world_limit_left.value = world_limits.limit_left()
	_item_world_limit_top.value = world_limits.limit_top()
	_item_world_limit_right.value = world_limits.limit_right()
	_item_world_limit_bottom.value = world_limits.limit_bottom()

	_item_world_limit_left.value_changed.connect(_on_item_left_changed)
	_item_world_limit_right.value_changed.connect(_on_item_right_changed)
	_item_world_limit_top.value_changed.connect(_on_item_top_changed)
	_item_world_limit_bottom.value_changed.connect(_on_item_bottom_changed)
