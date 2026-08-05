class_name InterfaceRNG
extends AppEditorInterface


func _ready() -> void:
	var item_seed := ItemString.new()
	item_seed.text = "Seed:"
	item_seed.placeholder_text = "(Random)"
	item_seed.value = project.game.rng.rng_seed
	item_seed.value_changed.connect(_on_item_seed_changed)

	var item_state := ItemString.new()
	item_state.text = "State:"
	item_state.placeholder_text = "(Initial state)"
	item_state.value = project.game.rng.rng_state
	item_state.value_changed.connect(_on_item_state_changed)

	project.game.rng.seed_changed.connect(
			_on_game_rng_seed_changed.bind(item_seed, item_state).unbind(2)
	)
	project.game.rng.state_changed.connect(
			_on_game_rng_state_changed.bind(item_state).unbind(2)
	)

	_refresh_item_visiblity(item_seed, item_state)

	closed.connect(navigator.close_interface)


## Makes the state item only visible when the seed is not random
func _refresh_item_visiblity(
		item_seed: ItemString, item_state: ItemString
) -> void:
	var child_items: Array[PropertyTreeItem] = [ item_seed ]
	if not item_seed.value.is_empty():
		child_items.append(item_state)

	var game_settings := %GameSettingsCategory as ItemVoidNode
	game_settings.item.child_items = child_items
	game_settings.refresh()


func _on_item_seed_changed(item: ItemString) -> void:
	_apply_undo_redo_property(
			"Change RNG seed",
			project.game.rng,
			&"rng_seed",
			project.game.rng.rng_seed,
			item.value
	)


func _on_item_state_changed(item: ItemString) -> void:
	_apply_undo_redo_property(
			"Change RNG state",
			project.game.rng,
			&"rng_state",
			project.game.rng.rng_state,
			item.value
	)


func _on_game_rng_seed_changed(
		item_seed: ItemString, item_state: ItemString
) -> void:
	_set_setting_no_signal(
			item_seed, _on_item_seed_changed, project.game.rng.rng_seed
	)

	_refresh_item_visiblity(item_seed, item_state)


func _on_game_rng_state_changed(item_state: ItemString) -> void:
	_set_setting_no_signal(
			item_state, _on_item_state_changed, project.game.rng.rng_state
	)
