class_name DecorationVisualsContainer2D
extends Node2D
## An encapsulated list of [DecorationVisuals2D].

signal decoration_visuals_created(decoration_visuals: DecorationVisuals2D)

## The scene's root node must extend [DecorationVisuals2D].
const _DECORATION_VISUALS_SCENE: PackedScene = preload("uid://dkm408u40wfix")

var _world_decorations: WorldDecorations

## Maps a world decoration to its corresponding visuals node.
var _map: Dictionary[WorldDecoration, DecorationVisuals2D] = {}


func setup(decorations: WorldDecorations) -> void:
	if _world_decorations != null:
		_world_decorations.added.disconnect(_add)
		_world_decorations.removed.disconnect(_remove)

	_world_decorations = decorations

	_world_decorations.added.connect(_add)
	_world_decorations.removed.connect(_remove)

	if is_node_ready():
		_refresh()
	else:
		ready.connect(_refresh, ConnectFlags.CONNECT_ONE_SHOT)


func _refresh() -> void:
	NodeUtils.delete_all_children(self)
	_map.clear()

	for decoration in _world_decorations.list():
		_add(decoration)


## Returns null if the decoration has no visuals.
func visuals_of(decoration: WorldDecoration) -> DecorationVisuals2D:
	return _map.get(decoration)


## Returns a new copy of this list.
func all_visuals() -> Array[DecorationVisuals2D]:
	return _map.values()


func _add(decoration: WorldDecoration) -> void:
	if not is_node_ready():
		return

	var decoration_visuals := (
			_DECORATION_VISUALS_SCENE.instantiate() as DecorationVisuals2D
	)
	decoration_visuals.world_decoration = decoration
	_map[decoration] = decoration_visuals
	add_child(decoration_visuals)
	decoration_visuals_created.emit(decoration_visuals)


func _remove(decoration: WorldDecoration) -> void:
	if not is_node_ready():
		return

	NodeUtils.delete_node(_map[decoration])
	_map.erase(decoration)
