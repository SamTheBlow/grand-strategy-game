class_name InterfaceWorldLimits
extends AppEditorInterface

var _is_setup: bool = false
var _world_limits: WorldLimits

var _item_custom_limits_enabled := ItemBool.new()
var _item_world_limit_left := ItemInt.new()
var _item_world_limit_right := ItemInt.new()
var _item_world_limit_top := ItemInt.new()
var _item_world_limit_bottom := ItemInt.new()

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode


func _init() -> void:
	_item_custom_limits_enabled.text = "Custom world limits"
	_item_world_limit_left.text = "Left"
	_item_world_limit_right.text = "Right"
	_item_world_limit_top.text = "Top"
	_item_world_limit_bottom.text = "Bottom"


func _ready() -> void:
	if _is_setup:
		_update()


func setup(world_limits: WorldLimits) -> void:
	if _is_setup:
		_world_limits.mode_changed.disconnect(_update_limits_mode)
		_world_limits.current_limits_changed.disconnect(_update_limit_items)
	else:
		_item_custom_limits_enabled.value_changed.connect(_set_limits_mode)
		_item_world_limit_left.value_changed.connect(_set_limit_left)
		_item_world_limit_top.value_changed.connect(_set_limit_top)
		_item_world_limit_right.value_changed.connect(_set_limit_right)
		_item_world_limit_bottom.value_changed.connect(_set_limit_bottom)

	_world_limits = world_limits
	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	_update_limits_mode()
	_update_limit_items()
	_update_editor_settings()
	_update_game_settings()
	_world_limits.mode_changed.connect(_update_limits_mode)
	_world_limits.current_limits_changed.connect(_update_limit_items)


func _update_editor_settings() -> void:
	if not is_node_ready() or not _is_setup:
		return
	_editor_settings_node.item.child_items = [
		editor_settings.show_world_limits
	]
	_editor_settings_node.refresh()


func _update_game_settings() -> void:
	_game_settings_node.item.child_items = [
		_item_custom_limits_enabled,
		_item_world_limit_left,
		_item_world_limit_right,
		_item_world_limit_top,
		_item_world_limit_bottom,
	]
	_game_settings_node.refresh()


func _update_limits_mode() -> void:
	_item_custom_limits_enabled.value_changed.disconnect(_set_limits_mode)
	_item_custom_limits_enabled.value = _world_limits.is_custom_limits_enabled()
	_item_custom_limits_enabled.value_changed.connect(_set_limits_mode)


func _update_limit_items(_limits: WorldLimits = null) -> void:
	_item_world_limit_left.value_changed.disconnect(_set_limit_left)
	_item_world_limit_top.value_changed.disconnect(_set_limit_top)
	_item_world_limit_right.value_changed.disconnect(_set_limit_right)
	_item_world_limit_bottom.value_changed.disconnect(_set_limit_bottom)

	var is_disabled: bool = not _world_limits.is_custom_limits_enabled()
	_item_world_limit_left.value = _world_limits.limit_left()
	_item_world_limit_left.is_disabled = is_disabled
	_item_world_limit_top.value = _world_limits.limit_top()
	_item_world_limit_top.is_disabled = is_disabled
	_item_world_limit_right.value = _world_limits.limit_right()
	_item_world_limit_right.is_disabled = is_disabled
	_item_world_limit_bottom.value = _world_limits.limit_bottom()
	_item_world_limit_bottom.is_disabled = is_disabled

	_item_world_limit_left.value_changed.connect(_set_limit_left)
	_item_world_limit_top.value_changed.connect(_set_limit_top)
	_item_world_limit_right.value_changed.connect(_set_limit_right)
	_item_world_limit_bottom.value_changed.connect(_set_limit_bottom)


func _set_limits_mode(_item: PropertyTreeItem) -> void:
	if _item_custom_limits_enabled.value:
		undo_redo.create_action("Enable custom world limits")
		undo_redo.add_do_method(_world_limits.enable_custom_limits)
		undo_redo.add_undo_method(_world_limits.disable_custom_limits)
		undo_redo.commit_action()
	else:
		undo_redo.create_action("Disable custom world limits")
		undo_redo.add_do_method(_world_limits.disable_custom_limits)
		undo_redo.add_undo_method(_world_limits.enable_custom_limits)
		undo_redo.commit_action()


func _set_limit_left(_item: PropertyTreeItem) -> void:
	undo_redo.create_action("Set custom world limits, left side")
	undo_redo.add_do_method(_world_limits.set_custom_limit_left.bind(
			_item_world_limit_left.value
	))
	undo_redo.add_undo_method(_world_limits.set_custom_limit_left.bind(
			_world_limits.custom_limits.x
	))
	undo_redo.commit_action()


func _set_limit_top(_item: PropertyTreeItem) -> void:
	undo_redo.create_action("Set custom world limits, top side")
	undo_redo.add_do_method(_world_limits.set_custom_limit_top.bind(
			_item_world_limit_top.value
	))
	undo_redo.add_undo_method(_world_limits.set_custom_limit_top.bind(
			_world_limits.custom_limits.y
	))
	undo_redo.commit_action()


func _set_limit_right(_item: PropertyTreeItem) -> void:
	undo_redo.create_action("Set custom world limits, right side")
	undo_redo.add_do_method(_world_limits.set_custom_limit_right.bind(
			_item_world_limit_right.value
	))
	undo_redo.add_undo_method(_world_limits.set_custom_limit_right.bind(
			_world_limits.custom_limits.z
	))
	undo_redo.commit_action()


func _set_limit_bottom(_item: PropertyTreeItem) -> void:
	undo_redo.create_action("Set custom world limits, bottom side")
	undo_redo.add_do_method(_world_limits.set_custom_limit_bottom.bind(
			_item_world_limit_bottom.value
	))
	undo_redo.add_undo_method(_world_limits.set_custom_limit_bottom.bind(
			_world_limits.custom_limits.w
	))
	undo_redo.commit_action()
