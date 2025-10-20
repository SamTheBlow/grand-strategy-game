class_name ProvinceVisualsContainer2D
extends Node2D
## An encapsulated list of [ProvinceVisuals2D].

# TODO there is probably a better way to do this
signal province_mouse_entered(province_visuals: ProvinceVisuals2D)
signal province_mouse_exited(province_visuals: ProvinceVisuals2D)
signal unhandled_mouse_event_occured(
		event: InputEventMouse, province_visuals: ProvinceVisuals2D
)

const _PROVINCE_VISUALS_SCENE := preload("uid://cppfb8jwghnqt") as PackedScene

var _is_setup: bool = false
var _provinces: Provinces

## A list of all the child nodes, for easy access.
var _list: Array[ProvinceVisuals2D] = []

## Maps a province id to its visuals, for performance reasons.
var _province_map: Dictionary[int, ProvinceVisuals2D] = {}


func _ready() -> void:
	if _is_setup:
		_update()


func setup(provinces: Provinces) -> void:
	if _is_setup and is_node_ready():
		_disconnect_signals()

	_provinces = provinces

	_is_setup = true

	if is_node_ready():
		_update()


## Returns null if given province doesn't have visuals.
func visuals_of(province_id: int) -> ProvinceVisuals2D:
	if _province_map.has(province_id):
		return _province_map[province_id]
	return null


func _update() -> void:
	_clear()

	for province in _provinces.list():
		_add_province(province)

	_connect_signals()


## No effect if the province already has visuals.
func _add_province(province: Province) -> void:
	if _province_map.has(province.id):
		return

	var province_visuals := (
			_PROVINCE_VISUALS_SCENE.instantiate() as ProvinceVisuals2D
	)
	province_visuals.province = province

	_list.append(province_visuals)
	_province_map[province.id] = province_visuals

	province_visuals.unhandled_mouse_event_occured.connect(
			unhandled_mouse_event_occured.emit
	)
	province_visuals.mouse_entered.connect(
			province_mouse_entered.emit.bind(province_visuals)
	)
	province_visuals.mouse_exited.connect(
			province_mouse_exited.emit.bind(province_visuals)
	)

	add_child(province_visuals)


## No effect if the province didn't have visuals.
func _remove_province(province: Province) -> void:
	if not _province_map.has(province.id):
		return
	var province_visuals: ProvinceVisuals2D = _province_map[province.id]
	_province_map.erase(province.id)
	_list.erase(province_visuals)
	remove_child(province_visuals)
	province_visuals.queue_free()


## Removes all province visuals.
func _clear() -> void:
	NodeUtils.remove_all_children(self)
	_list = []
	_province_map = {}


func _connect_signals() -> void:
	_provinces.added.connect(_add_province)
	_provinces.removed.connect(_remove_province)


func _disconnect_signals() -> void:
	_provinces.added.disconnect(_add_province)
	_provinces.removed.disconnect(_remove_province)
