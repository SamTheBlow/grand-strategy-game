class_name ArmyMovementPopup
extends VBoxContainer
## Contents for the popup that appears when the user wants to move an [Army].
##
## See also: [GamePopup]

signal invalidated()
signal confirmed(army: Army, troop_count: int, destination_province_id: int)

var _is_invalid: bool = false

var _is_setup: bool = false
var _army: Army
var _provinces: Provinces
var _destination_province_id: int

@onready var _troop_slider := %HSlider as Slider
@onready var _troop_label := %Label as Label


func _ready() -> void:
	if _is_setup:
		_update()


func buttons() -> Array[String]:
	return ["Cancel", "Confirm"]


func setup(
		army: Army, provinces: Provinces, destination_province_id: int
) -> void:
	if _is_setup:
		_provinces.removed.disconnect(_on_province_removed)

	_army = army
	_provinces = provinces
	_destination_province_id = destination_province_id
	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	if (
			_army.province(_provinces) == null
			or _provinces.province_from_id(_destination_province_id) == null
	):
		_is_invalid = true
		invalidated.emit()
		return

	_provinces.removed.connect(_on_province_removed)

	_troop_slider.min_value = _army.army_size.minimum()
	_troop_slider.max_value = _army.army_size.current_size()

	# Default to moving the entire army
	_troop_slider.value = _troop_slider.max_value

	_update_label()


func _update_label() -> void:
	var value := int(_troop_slider.value)
	var max_value := int(_troop_slider.max_value)
	_troop_label.text = str(value) + " | " + str(max_value - value)


func _on_troop_slider_value_changed(value: float) -> void:
	if (
			value > _troop_slider.max_value - _army.army_size.minimum()
			and value < _troop_slider.max_value
	):
		# We return early, because setting the slider's value here
		# triggers the signal that calls this function
		_troop_slider.value = _troop_slider.max_value
		return

	_update_label()


func _on_button_pressed(button_id: int) -> void:
	if button_id == 1:
		var troop_count := int(_troop_slider.value)
		confirmed.emit(_army, troop_count, _destination_province_id)


func _on_province_removed(province: Province) -> void:
	if (
			province.id == _destination_province_id
			or province.id == _army.province_id()
	):
		_is_invalid = true
		_provinces.removed.disconnect(_on_province_removed)
		invalidated.emit()
