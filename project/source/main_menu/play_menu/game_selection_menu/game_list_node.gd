class_name GameListNode
extends VBoxContainer
## Shows a list of game projects for the user to choose from.

signal project_selected(game_id: int)

var _list: Array[GameOptionNode] = []


func add_game(meta_bundle: MetadataBundle, game_id: int) -> void:
	var new_option := (
			preload("uid://b65o5apaw32").instantiate() as GameOptionNode
	)
	new_option.meta_bundle = meta_bundle
	new_option.id = game_id
	new_option.selected.connect(_on_project_selected)

	var project_settings := (
			preload("uid://7dfhary26tgm").instantiate() as ProjectSettingsNode
	)
	new_option.settings = project_settings

	add_child(new_option)
	add_child(project_settings)
	_list.append(new_option)


## Calls add_game for each file path in given array.
func add_games(
		game_data_array: Array[MetadataBundle], starting_game_id: int
) -> void:
	var game_id: int = starting_game_id
	for meta_bundle in game_data_array:
		add_game(meta_bundle, game_id)
		game_id += 1


func clear() -> void:
	NodeUtils.remove_all_children(self)
	_list.clear()


## Returns null if there is no game with given id.
func game_with_id(game_id: int) -> GameOptionNode:
	for option_node in _list:
		if option_node.id == game_id:
			return option_node
	return null


func _on_project_selected(option_node: GameOptionNode) -> void:
	project_selected.emit(option_node.id)
