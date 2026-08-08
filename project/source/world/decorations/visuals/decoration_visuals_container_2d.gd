class_name DecorationVisualsContainer2D
extends Node2D
## An encapsulated list of [DecorationVisuals2D].

signal decoration_visuals_created(decoration_visuals: DecorationVisuals2D)
signal decoration_hovered(decoration: WorldDecoration)
signal decoration_unhovered()

## The scene's root node must extend [DecorationVisuals2D].
const _DECORATION_VISUALS_SCENE: PackedScene = preload("uid://dkm408u40wfix")

var _world_decorations: WorldDecorations

## Maps a world decoration to its corresponding visuals node.
var _map: Dictionary[WorldDecoration, DecorationVisuals2D] = {}


func setup(decorations: WorldDecorations) -> void:
	if not is_node_ready():
		ready.connect(setup.bind(decorations), ConnectFlags.CONNECT_ONE_SHOT)
		return

	if _world_decorations != null:
		_world_decorations.added.disconnect(_add)
		_world_decorations.removed.disconnect(_remove)

		# Remove all
		NodeUtils.delete_all_children(self)
		_map.clear()

	_world_decorations = decorations

	if _world_decorations != null:
		# Add all
		for decoration in _world_decorations.list():
			_add(decoration)

		_world_decorations.added.connect(_add)
		_world_decorations.removed.connect(_remove)


func clear() -> void:
	setup(null)


## Returns null if the decoration has no visuals.
func visuals_of(decoration: WorldDecoration) -> DecorationVisuals2D:
	return _map.get(decoration)


## Returns a new copy of this list.
func all_visuals() -> Array[DecorationVisuals2D]:
	return _map.values()


func _add(decoration: WorldDecoration) -> void:
	var decoration_visuals := (
			_DECORATION_VISUALS_SCENE.instantiate() as DecorationVisuals2D
	)
	decoration_visuals.world_decoration = decoration
	decoration_visuals.mouse_entered.connect(
			decoration_hovered.emit.bind(decoration)
	)
	decoration_visuals.mouse_exited.connect(decoration_unhovered.emit)
	_map[decoration] = decoration_visuals
	add_child(decoration_visuals)
	decoration_visuals_created.emit(decoration_visuals)


func _remove(decoration: WorldDecoration) -> void:
	NodeUtils.delete_node(_map[decoration])
	_map.erase(decoration)
