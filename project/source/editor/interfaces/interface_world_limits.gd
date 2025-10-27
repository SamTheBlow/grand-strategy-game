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
		_world_limits.current_limits_changed.disconnect(_update_limit_items)
		_world_limits.mode_changed.disconnect(_update_mode_item)
	else:
		_item_custom_limits_enabled.value_changed.connect(_on_limits_toggled)
		_item_world_limit_left.value_changed.connect(_update_limit_left)
		_item_world_limit_top.value_changed.connect(_update_limit_top)
		_item_world_limit_right.value_changed.connect(_update_limit_right)
		_item_world_limit_bottom.value_changed.connect(_update_limit_bottom)

	_world_limits = world_limits
	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	_update_mode_item()
	_update_limit_items()
	_update_editor_settings()
	_update_game_settings()
	_world_limits.current_limits_changed.connect(_update_limit_items)
	_world_limits.mode_changed.connect(_update_mode_item)


func _update_editor_settings() -> void:
	if not is_node_ready() or not _is_setup:
		return
	_editor_settings_node.item.child_items = [
		editor_settings.show_world_limits
	]
	_editor_settings_node.refresh()


func _update_game_settings() -> void:
	if not is_node_ready() or not _is_setup:
		return
	_game_settings_node.item.child_items = [
		_item_custom_limits_enabled,
		_item_world_limit_left,
		_item_world_limit_right,
		_item_world_limit_top,
		_item_world_limit_bottom,
	]
	_game_settings_node.refresh()


func _update_limit_items(_limits: WorldLimits = null) -> void:
	# Temporarily disconnect signals to avoid side effects
	_item_world_limit_left.value_changed.disconnect(_update_limit_left)
	_item_world_limit_top.value_changed.disconnect(_update_limit_top)
	_item_world_limit_right.value_changed.disconnect(_update_limit_right)
	_item_world_limit_bottom.value_changed.disconnect(_update_limit_bottom)

	var is_disabled: bool = not _world_limits.is_custom_limits_enabled()
	_item_world_limit_left.value = _world_limits.limit_left()
	_item_world_limit_left.is_disabled = is_disabled
	_item_world_limit_top.value = _world_limits.limit_top()
	_item_world_limit_top.is_disabled = is_disabled
	_item_world_limit_right.value = _world_limits.limit_right()
	_item_world_limit_right.is_disabled = is_disabled
	_item_world_limit_bottom.value = _world_limits.limit_bottom()
	_item_world_limit_bottom.is_disabled = is_disabled

	# Reconnect signals
	_item_world_limit_left.value_changed.connect(_update_limit_left)
	_item_world_limit_top.value_changed.connect(_update_limit_top)
	_item_world_limit_right.value_changed.connect(_update_limit_right)
	_item_world_limit_bottom.value_changed.connect(_update_limit_bottom)


func _update_mode_item() -> void:
	_item_custom_limits_enabled.value = _world_limits.is_custom_limits_enabled()


func _update_limit_left(_item: PropertyTreeItem) -> void:
	_world_limits.custom_limits.x = _item_world_limit_left.value


func _update_limit_top(_item: PropertyTreeItem) -> void:
	_world_limits.custom_limits.y = _item_world_limit_top.value


func _update_limit_right(_item: PropertyTreeItem) -> void:
	_world_limits.custom_limits.z = _item_world_limit_right.value


func _update_limit_bottom(_item: PropertyTreeItem) -> void:
	_world_limits.custom_limits.w = _item_world_limit_bottom.value


func _on_limits_toggled(_item: PropertyTreeItem) -> void:
	if _item_custom_limits_enabled.value:
		_world_limits.enable_custom_limits()
	else:
		_world_limits.disable_custom_limits()
