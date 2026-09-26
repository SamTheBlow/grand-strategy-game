class_name ProjectOptionContainer
extends FoldableContainer
## Holds a list of [GameOptionNode]s for the user to select.

signal selected(option_node: GameOptionNode)

const _GAME_OPTION_SCENE: PackedScene = preload("uid://b65o5apaw32")

@export var _container: VBoxContainer

## Maps each option to its project file path.
var projects: Dictionary[String, GameOptionNode] = {}


func add_option(meta_bundle: MetadataBundle) -> void:
	var option_node := _GAME_OPTION_SCENE.instantiate() as GameOptionNode
	option_node.meta_bundle = meta_bundle
	option_node.selected.connect(selected.emit)
	_container.add_child(option_node)
	projects[meta_bundle.project_absolute_path] = option_node

	visible = true
	expand()
