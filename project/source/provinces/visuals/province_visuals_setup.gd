class_name ProvinceVisualsSetup
extends Node
## Adds and removes province visuals to match given [Provinces].

var provinces := Provinces.new():
	set(value):
		_disconnect_signals()
		provinces = value
		_update()

@onready var _province_selection := %ProvinceSelection as ProvinceSelection
@onready var _container := %Provinces as ProvinceVisualsContainer2D


func _ready() -> void:
	_update()


func _update() -> void:
	if not is_node_ready():
		return

	_container.clear()
	for province in provinces.list():
		_container.add_province(province)

	_connect_signals()


func _connect_signals() -> void:
	provinces.added.connect(_container.add_province)
	provinces.removed.connect(_province_selection.deselect_province)
	provinces.removed.connect(_container.remove_province)


func _disconnect_signals() -> void:
	if not is_node_ready():
		return

	provinces.added.disconnect(_container.add_province)
	provinces.removed.disconnect(_province_selection.deselect_province)
	provinces.removed.disconnect(_container.remove_province)
