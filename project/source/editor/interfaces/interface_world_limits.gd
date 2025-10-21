class_name InterfaceWorldLimits
extends AppEditorInterface

var _item_world_limit_left := ItemInt.new()
var _item_world_limit_right := ItemInt.new()
var _item_world_limit_top := ItemInt.new()
var _item_world_limit_bottom := ItemInt.new()

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode


func _ready() -> void:
	_item_world_limit_left.text = game_settings.custom_world_limit_left.text
	_item_world_limit_left.is_disabled = true
	_item_world_limit_right.text = game_settings.custom_world_limit_right.text
	_item_world_limit_right.is_disabled = true
	_item_world_limit_top.text = game_settings.custom_world_limit_top.text
	_item_world_limit_top.is_disabled = true
	_item_world_limit_bottom.text = game_settings.custom_world_limit_bottom.text
	_item_world_limit_bottom.is_disabled = true
	_update_limit_items()
	super()
	game_settings.world_limits.current_limits_changed.connect(
			_update_limit_items
	)
	game_settings.custom_world_limits_enabled.value_changed.connect(
			_on_limits_toggled
	)


func _update_editor_settings() -> void:
	if not is_node_ready():
		return
	_editor_settings_node.item.child_items = [
		editor_settings.show_world_limits
	]
	_editor_settings_node.refresh()


func _update_game_settings() -> void:
	if not is_node_ready():
		return

	if game_settings.custom_world_limits_enabled.value:
		_game_settings_node.item.child_items = [
			game_settings.custom_world_limits_enabled,
			game_settings.custom_world_limit_left,
			game_settings.custom_world_limit_right,
			game_settings.custom_world_limit_top,
			game_settings.custom_world_limit_bottom,
		]
	else:
		_game_settings_node.item.child_items = [
			game_settings.custom_world_limits_enabled,
			_item_world_limit_left,
			_item_world_limit_right,
			_item_world_limit_top,
			_item_world_limit_bottom,
		]

	_game_settings_node.refresh()


func _update_limit_items(_world_limits: WorldLimits = null) -> void:
	_item_world_limit_left.value = game_settings.world_limits.limit_left()
	_item_world_limit_top.value = game_settings.world_limits.limit_top()
	_item_world_limit_right.value = game_settings.world_limits.limit_right()
	_item_world_limit_bottom.value = game_settings.world_limits.limit_bottom()


func _on_limits_toggled(_item: PropertyTreeItem) -> void:
	_update_game_settings()
