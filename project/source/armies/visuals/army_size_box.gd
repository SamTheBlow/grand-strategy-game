@tool
class_name ArmySizeBox
extends Control
## Displays given [Army]'s size
## inside a box colored after the army's owner country.
## Automatically updates itself when something changes.
##
## Note that this node updates its own anchor points.


const PARENT_SIZE_X: float = 64.0
const BOX_LEFT_RIGHT_MARGIN: float = 4.0
const BOX_OUTLINE_THICKNESS: float = 4.0

## Editor only. Meant for debugging.
@export var _simulated_country_color := Color.RED:
	set(value):
		_simulated_country_color = value
		_refresh_box()

## Editor only. Meant for debugging.
@export var _simulated_army_size: int = 9_999_999_999:
	set(value):
		_simulated_army_size = value
		_on_army_size_changed(_simulated_army_size)

var army: Army:
	set(value):
		_disconnect_signals()
		army = value
		_connect_signals()
		_refresh()

var _box: ColoredBox
@onready var _label := %ArmySizeLabel as Label


func _ready() -> void:
	_box = ColoredBox.new()
	_box.show_behind_parent = true
	_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box, false, Node.INTERNAL_MODE_FRONT)

	if Engine.is_editor_hint():
		_on_army_size_changed(_simulated_army_size)
		return

	_refresh()


func _refresh() -> void:
	if army == null and not Engine.is_editor_hint():
		_box.hide()
		return

	_on_army_allegiance_changed(army.owner_country)
	_on_army_size_changed(army.army_size.current_size())
	_box.show()


func _refresh_box() -> void:
	if _box == null:
		return

	_box.box_global_position = global_position
	_box.box_size = size
	_box.left_right_margin = BOX_LEFT_RIGHT_MARGIN
	_box.is_outline_inside = true
	if army != null:
		_box.outline_width = BOX_OUTLINE_THICKNESS
		_box.outline_color = army.owner_country.color
	elif Engine.is_editor_hint():
		_box.outline_width = BOX_OUTLINE_THICKNESS
		_box.outline_color = _simulated_country_color
	else:
		_box.outline_width = 0.0

	_box.queue_redraw()


## Updates this node's anchors such that
## the text and the box both fit inside this node's transform.
func _refresh_anchors() -> void:
	var text_start: float = _label.get_character_bounds(0).position.x
	var text_end: float = (
			_label.get_character_bounds(_label.text.length() - 1).end.x
	)
	var text_width: float = text_end - text_start
	var box_width: float = (
			text_width
			+ BOX_LEFT_RIGHT_MARGIN * 2.0
			+ BOX_OUTLINE_THICKNESS * 2.0
	)
	var anchor_delta: float = box_width / (PARENT_SIZE_X * 2.0)

	anchor_left = 0.5 - anchor_delta
	anchor_right = 0.5 + anchor_delta


func _disconnect_signals() -> void:
	if army == null:
		return

	if army.allegiance_changed.is_connected(_on_army_allegiance_changed):
		army.allegiance_changed.disconnect(_on_army_allegiance_changed)
	if army.size_changed.is_connected(_on_army_size_changed):
		army.size_changed.disconnect(_on_army_size_changed)


func _connect_signals() -> void:
	if army == null:
		return

	if not army.allegiance_changed.is_connected(_on_army_allegiance_changed):
		army.allegiance_changed.connect(_on_army_allegiance_changed)
	if not army.size_changed.is_connected(_on_army_size_changed):
		army.size_changed.connect(_on_army_size_changed)


func _on_army_allegiance_changed(_owner_country: Country) -> void:
	_refresh_box.call_deferred()


func _on_army_size_changed(new_army_size: int) -> void:
	if not is_node_ready():
		return

	_label.text = str(new_army_size)
	_refresh_anchors()
	_refresh_box.call_deferred()
