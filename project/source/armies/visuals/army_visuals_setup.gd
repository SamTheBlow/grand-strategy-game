class_name ArmyVisualsSetup
extends Node
## Creates an [ArmyVisuals2D] for each army in given [Armies].
## Assigns those army visuals to the correct [ProvinceVisuals2D].

## Make sure to set this before setting armies...
var playing_country: PlayingCountry

var armies: Armies:
	set(value):
		_disconnect_signals()
		armies = value
		_initialize()

@export var _provinces_container: ProvinceVisualsContainer2D

## The scene's root node must extend [ArmyVisuals2D].
@export var _army_visuals_scene: PackedScene


func _disconnect_signals() -> void:
	if armies == null:
		return

	if armies.army_added.is_connected(_on_army_added):
		armies.army_added.disconnect(_on_army_added)


func _initialize() -> void:
	for army in armies.list():
		_add_army(army)

	if not armies.army_added.is_connected(_on_army_added):
		armies.army_added.connect(_on_army_added)


func _add_army(army: Army) -> void:
	var new_army_visuals := _army_visuals_scene.instantiate() as ArmyVisuals2D
	new_army_visuals.army = army
	new_army_visuals.playing_country = playing_country

	# Why call_deferred?
	# Because we need to give time for the province visuals to spawn.
	_on_province_changed.call_deferred(new_army_visuals)

	new_army_visuals.province_changed.connect(_on_province_changed)

	# TODO bad code: private function
	armies.army_removed.connect(new_army_visuals._on_army_removed)


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
