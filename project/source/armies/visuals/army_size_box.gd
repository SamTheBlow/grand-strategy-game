@tool
class_name ArmySizeBox
extends Control
## Displays a number inside a colored box.
## Resizes the box according to the size of the number text.
##
## Note that this node updates its own anchor points.

const _PARENT_SIZE_X: float = 64.0
const _BOX_LEFT_RIGHT_MARGIN: float = 4.0
const _BOX_OUTLINE_THICKNESS: float = 4.0

@export var color := Color.RED:
	set(value):
		color = value

		_box.outline_color = color
		_box.queue_redraw()

@export var number: int = 9_999_999_999:
	set(value):
		number = value

		_label.text = str(number)
		_refresh_anchors()
		_refresh_box.call_deferred()

var _box: ColoredBox

@onready var _label := %ArmySizeLabel as Label


func _ready() -> void:
	_box = ColoredBox.new()
	_box.show_behind_parent = true
	_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_box.left_right_margin = _BOX_LEFT_RIGHT_MARGIN
	_box.is_outline_inside = true
	_box.outline_width = _BOX_OUTLINE_THICKNESS

	add_child(_box, false, Node.INTERNAL_MODE_FRONT)

	_box.outline_color = color
	_box.queue_redraw()

	_label.text = str(number)
	_refresh_anchors()
	_refresh_box.call_deferred()


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
			+ _BOX_LEFT_RIGHT_MARGIN * 2.0
			+ _BOX_OUTLINE_THICKNESS * 2.0
	)
	var anchor_delta: float = box_width / (_PARENT_SIZE_X * 2.0)

	anchor_left = 0.5 - anchor_delta
	anchor_right = 0.5 + anchor_delta


func _refresh_box() -> void:
	_box.box_global_position = global_position
	_box.box_size = size
	_box.queue_redraw()
