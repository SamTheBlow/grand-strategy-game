class_name ProjectOptionContainer
extends FoldableContainer
## Holds a list of [GameOptionNode]s for the user to select.

signal selected(option_node: GameOptionNode)

const _GAME_OPTION_SCENE: PackedScene = preload("uid://b65o5apaw32")

## If true, adding an option automatically emits selected for that option.
@export var select_when_added: bool = false

@export var _container: VBoxContainer


func add_option(meta_bundle: MetadataBundle) -> void:
	var option_node := _GAME_OPTION_SCENE.instantiate() as GameOptionNode
	option_node.meta_bundle = meta_bundle
	option_node.selected.connect(selected.emit)
	_container.add_child(option_node)

	visible = true
	expand()

	if select_when_added:
		selected.emit(option_node)
