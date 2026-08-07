class_name ProvinceVisualsContainer2D
extends Node2D
## An encapsulated list of [ProvinceVisuals2D].

signal province_clicked(province: Province)
signal province_right_clicked(
		is_double_click: bool, province_visuals: ProvinceVisuals2D
)
signal province_mouse_entered(province_visuals: ProvinceVisuals2D)
signal province_mouse_exited(province_visuals: ProvinceVisuals2D)
signal province_tree_exited(province_visuals: ProvinceVisuals2D)

const _PROVINCE_VISUALS_SCENE := preload("uid://cppfb8jwghnqt") as PackedScene

var _provinces: Provinces

## Maps a province id to its visuals.
var _province_map: Dictionary[int, ProvinceVisuals2D] = {}


func setup(provinces: Provinces) -> void:
	if not is_node_ready():
		ready.connect(setup.bind(provinces), ConnectFlags.CONNECT_ONE_SHOT)
		return

	if _provinces != null:
		_provinces.added.disconnect(_add_province)
		_provinces.removed.disconnect(_remove_province)

		# Remove all
		NodeUtils.remove_all_children(self)
		_province_map.clear()

	_provinces = provinces

	if _provinces != null:
		# Add all
		for province in _provinces.list():
			_add_province(province)

		_provinces.added.connect(_add_province)
		_provinces.removed.connect(_remove_province)


func clear() -> void:
	setup(null)


## Returns null if given province doesn't have visuals.
func visuals_of(province_id: int) -> ProvinceVisuals2D:
	if _province_map.has(province_id):
		return _province_map[province_id]
	return null


func remove_all_highlights() -> void:
	for province_id in _province_map:
		_province_map[province_id].remove_highlight()


func _add_province(province: Province) -> void:
	var visuals := _PROVINCE_VISUALS_SCENE.instantiate() as ProvinceVisuals2D
	visuals.province = province
	visuals.clicked.connect(province_clicked.emit.bind(visuals.province))
	visuals.right_clicked.connect(province_right_clicked.emit.bind(visuals))
	visuals.mouse_entered.connect(province_mouse_entered.emit.bind(visuals))
	visuals.mouse_exited.connect(province_mouse_exited.emit.bind(visuals))
	visuals.tree_exited.connect(province_tree_exited.emit.bind(visuals))

	_province_map[province.id] = visuals
	add_child(visuals)


func _remove_province(province: Province) -> void:
	NodeUtils.delete_node(_province_map[province.id])
	_province_map.erase(province.id)
