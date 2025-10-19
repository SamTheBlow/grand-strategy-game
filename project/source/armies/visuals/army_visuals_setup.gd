class_name ArmyVisualsSetup
extends Node
## Creates an [ArmyVisuals2D] for each army in given [Armies].
## Assigns those army visuals to the correct [ProvinceVisuals2D].

## The scene's root node must extend [ArmyVisuals2D].
const _ARMY_VISUALS_SCENE := preload("uid://eso260jnknd4") as PackedScene

var playing_country: PlayingCountry

var armies := Armies.new():
	set(value):
		_disconnect_signals()
		armies = value
		_update()

@onready var _provinces_container := %Provinces as ProvinceVisualsContainer2D


func _ready() -> void:
	_update()


func _update() -> void:
	if not is_node_ready():
		return

	for army in armies.list():
		_add_army(army)

	_connect_signals()


func _add_army(army: Army) -> void:
	var new_army_visuals := _ARMY_VISUALS_SCENE.instantiate() as ArmyVisuals2D
	new_army_visuals.army = army
	new_army_visuals.playing_country = playing_country

	# Why call_deferred?
	# Because we need to give time for the province visuals to spawn.
	_on_province_changed.call_deferred(new_army_visuals)

	new_army_visuals.province_changed.connect(_on_province_changed)

	# TODO bad code: private function
	armies.army_removed.connect(new_army_visuals._on_army_removed)


func _connect_signals() -> void:
	armies.army_added.connect(_on_army_added)


func _disconnect_signals() -> void:
	if not is_node_ready():
		return
	armies.army_added.disconnect(_on_army_added)


func _on_army_added(army: Army) -> void:
	_add_army(army)


func _on_province_changed(army_visuals: ArmyVisuals2D) -> void:
	var province_visuals: ProvinceVisuals2D = (
			_provinces_container.visuals_of(army_visuals.army.province().id)
	)
	if province_visuals == null:
		push_error("Province has no visuals.")
		return

	province_visuals.add_army(army_visuals)
