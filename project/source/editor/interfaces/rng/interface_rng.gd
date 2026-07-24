class_name InterfaceRNG
extends AppEditorInterface

var game_rng: GameRNG:
	set(value):
		if game_rng != null:
			game_rng.seed_changed.disconnect(_on_game_rng_seed_changed)
			game_rng.state_changed.disconnect(_on_game_rng_state_changed)

		game_rng = value

		game_rng.seed_changed.connect(_on_game_rng_seed_changed)
		game_rng.state_changed.connect(_on_game_rng_state_changed)

		if is_node_ready():
			_refresh()

var _item_seed := ItemString.new()
var _item_state := ItemString.new()

@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode


func _ready() -> void:
	# This is just so that this node still works by itself in the Godot editor
	if game_rng == null:
		game_rng = GameRNG.new()

	_item_seed.text = "Seed:"
	_item_seed.placeholder_text = "(Random)"
	_item_seed.value_changed.connect(_on_seed_value_changed)

	_item_state.text = "State:"
	_item_state.placeholder_text = "(Initial state)"
	_item_state.value_changed.connect(_on_state_value_changed)

	_refresh()


## Updates the interface to match the game's data
func _refresh() -> void:
	_update_seed_item()
	_update_state_item()

	# Make state only visible when seed is not random
	var child_items: Array[PropertyTreeItem] = [_item_seed]
	if not _item_seed.value.is_empty():
		child_items.append(_item_state)
	_game_settings_node.item.child_items = child_items
	_game_settings_node.refresh()


## Updates the text field to match the game's data
func _update_seed_item() -> void:
	_item_seed.value_changed.disconnect(_on_seed_value_changed)
	_item_seed.value = game_rng.rng_seed
	_item_seed.value_changed.connect(_on_seed_value_changed)


## Updates the text field to match the game's data
func _update_state_item() -> void:
	_item_state.value_changed.disconnect(_on_state_value_changed)
	_item_state.value = game_rng.rng_state
	_item_state.value_changed.connect(_on_state_value_changed)


## Updates the game data when user inputs new value
func _on_seed_value_changed(_item: PropertyTreeItem) -> void:
	# Wait one frame so that the text field can pick up the signal
	await get_tree().process_frame

	undo_redo.create_action("Change RNG seed")
	undo_redo.add_do_property(game_rng, &"rng_seed", _item_seed.value)
	undo_redo.add_undo_property(game_rng, &"rng_seed", game_rng.rng_seed)
	undo_redo.commit_action()


## Updates the game data when user inputs new value
func _on_state_value_changed(_item: PropertyTreeItem) -> void:
	# Wait one frame so that the text field can pick up the signal
	await get_tree().process_frame

	undo_redo.create_action("Change RNG state")
	undo_redo.add_do_property(game_rng, &"rng_state", _item_state.value)
	undo_redo.add_undo_property(game_rng, &"rng_state", game_rng.rng_state)
	undo_redo.commit_action()


func _on_game_rng_seed_changed(_before: String, _after: String) -> void:
	if is_node_ready():
		_refresh()


func _on_game_rng_state_changed(_before: String, _after: String) -> void:
	if is_node_ready():
		_update_state_item()
