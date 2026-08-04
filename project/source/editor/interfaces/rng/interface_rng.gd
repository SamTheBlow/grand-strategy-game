class_name InterfaceRNG
extends AppEditorInterface

var _item_seed := ItemString.new()
var _item_state := ItemString.new()


func _ready() -> void:
	_item_seed.text = "Seed:"
	_item_seed.placeholder_text = "(Random)"
	_item_seed.value = project.game.rng.rng_seed
	_item_seed.value_changed.connect(_on_item_seed_changed)
	project.game.rng.seed_changed.connect(_on_game_rng_seed_changed)

	_item_state.text = "State:"
	_item_state.placeholder_text = "(Initial state)"
	_item_state.value = project.game.rng.rng_state
	_item_state.value_changed.connect(_on_item_state_changed)
	project.game.rng.state_changed.connect(_on_game_rng_state_changed)

	_refresh_item_visiblity()

	closed.connect(navigator.close_interface)


## Makes the state item only visible when the seed is not random
func _refresh_item_visiblity() -> void:
	var child_items: Array[PropertyTreeItem] = [_item_seed]
	if not _item_seed.value.is_empty():
		child_items.append(_item_state)

	var game_settings := %GameSettingsCategory as ItemVoidNode
	game_settings.item.child_items = child_items
	game_settings.refresh()


func _on_item_seed_changed(_item: PropertyTreeItem) -> void:
	var game_rng: GameRNG = project.game.rng
	undo_redo.create_action("Change RNG seed")
	undo_redo.add_do_property(game_rng, &"rng_seed", _item_seed.value)
	undo_redo.add_undo_property(game_rng, &"rng_seed", game_rng.rng_seed)
	undo_redo.commit_action()


func _on_item_state_changed(_item: PropertyTreeItem) -> void:
	var game_rng: GameRNG = project.game.rng
	undo_redo.create_action("Change RNG state")
	undo_redo.add_do_property(game_rng, &"rng_state", _item_state.value)
	undo_redo.add_undo_property(game_rng, &"rng_state", game_rng.rng_state)
	undo_redo.commit_action()


func _on_game_rng_seed_changed(_before: String, _after: String) -> void:
	_item_seed.value_changed.disconnect(_on_item_seed_changed)
	_item_seed.value = project.game.rng.rng_seed
	_item_seed.value_changed.connect(_on_item_seed_changed)

	_refresh_item_visiblity()


func _on_game_rng_state_changed(_before: String, _after: String) -> void:
	_item_state.value_changed.disconnect(_on_item_state_changed)
	_item_state.value = project.game.rng.rng_state
	_item_state.value_changed.connect(_on_item_state_changed)
