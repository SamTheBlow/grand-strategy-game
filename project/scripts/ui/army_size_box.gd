@tool
class_name ArmySizeBox
extends Label


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


func _ready() -> void:
	_box = ColoredBox.new()
	_box.show_behind_parent = true
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
	_box.left_right_margin = 4.0
	_box.is_outline_inside = false
	if army != null:
		_box.outline_width = 4.0
		_box.outline_color = army.owner_country.color
	elif Engine.is_editor_hint():
		_box.outline_width = 4.0
		_box.outline_color = _simulated_country_color
	else:
		_box.outline_width = 0.0
	
	_box.queue_redraw()


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
	text = str(new_army_size)
	_refresh_box.call_deferred()
