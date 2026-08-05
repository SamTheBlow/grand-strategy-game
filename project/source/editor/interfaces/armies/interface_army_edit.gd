class_name InterfaceArmyEdit
extends AppEditorInterface
## The interface in which the user can edit given [Army].

var army: Army


func _ready() -> void:
	(%ArmyPreview as ArmyPreviewNode).setup(
			army, PlayingCountry.new(project.game)
	)

	_setup_settings(%Settings as ItemVoidNode)

	project.game.world.armies.removed.connect(_on_army_removed)

	closed.connect(navigator.open_new_interface.bind(
			InterfaceNavigator.InterfaceType.ARMY_LIST,
			project,
			editor_settings
	))


func _load_settings(settings_item: PropertyTreeItem) -> void:
	# Texture
	var item_texture := settings_item.child_items[0] as ItemTexture
	item_texture.fallback_texture = ArmyVisuals2D.DEFAULT_TEXTURE
	item_texture.value = army.texture
	item_texture.value_changed.connect(_on_item_texture_changed)
	item_texture.popup_requested.connect(
			texture_popup_requested.emit.bind(project.textures)
	)
	army.texture_changed.connect(
			_on_army_texture_changed.bind(item_texture)
	)

	# Owner country
	var item_country := settings_item.child_items[1] as ItemCountry
	item_country.make_unnullable(army.owner_country)
	item_country.value_changed.connect(_on_item_country_changed)
	item_country.change_requested.connect(country_select_pressed.emit)
	army.allegiance_changed.connect(
			_on_army_owner_changed.bind(item_country).unbind(1)
	)

	# Army size
	var item_size := settings_item.child_items[2] as ItemInt
	item_size.has_minimum = true
	item_size.minimum = army.size().minimum_value
	item_size.has_maximum = army.size().has_maximum()
	item_size.maximum = army.size().maximum_value
	item_size.value = army.size().value
	item_size.value_changed.connect(_on_item_size_changed)
	army.size().changed.connect(
			_on_army_size_changed.bind(item_size).unbind(1)
	)

	# Movements made
	var item_movements := settings_item.child_items[3] as ItemInt
	item_movements.has_minimum = true
	item_movements.minimum = 0
	item_movements.value = army.movements_made()
	item_movements.value_changed.connect(_on_item_moves_changed)
	army.movements_made_changed.connect(
			_on_army_movements_changed.bind(item_movements).unbind(1)
	)


func _delete() -> void:
	project.game.world.armies.undo_redo_remove(
			army, undo_redo, project.game.world.armies_in_each_province
	)


func _duplicate() -> void:
	# Create duplicate
	var new_army: Army = Army.Factory.new(project.game).new_army(
			army.owner_country,
			army.province_id(),
			army.size().value,
			-1,
			army.movements_made()
	)
	new_army.texture = army.texture

	# Create undo_redo action
	# (don't execute it since army setup already added the army)
	undo_redo.create_action("Duplicate army")
	undo_redo.add_do_method(project.game.world.armies.add.bind(new_army))
	undo_redo.add_undo_method(project.game.world.armies.remove.bind(new_army))
	undo_redo.commit_action(false)

	# Open interface to edit the new army
	navigator.open_army_edit_interface(new_army, project, editor_settings)


func _on_army_removed(army_removed: Army) -> void:
	if army_removed == army:
		closed.emit()


func _on_item_texture_changed(item: ItemTexture) -> void:
	_apply_undo_redo_action(
			"Change army sprite",
			army,
			&"texture",
			army.texture,
			item.value
	)


func _on_item_country_changed(item: ItemCountry) -> void:
	_apply_undo_redo_action(
			"Change army allegiance",
			army,
			&"owner_country",
			army.owner_country,
			item.value
	)


func _on_item_size_changed(item: ItemInt) -> void:
	_apply_undo_redo_action(
			"Change army size",
			army.size(),
			&"value",
			army.size().value,
			item.value
	)


func _on_item_moves_changed(item: ItemInt) -> void:
	_apply_undo_redo_action(
			"Change army movements made",
			army,
			&"_movements_made",
			army.movements_made(),
			item.value
	)


func _on_army_texture_changed(item: ItemTexture) -> void:
	_set_setting_no_signal(item, _on_item_texture_changed, army.texture)


func _on_army_owner_changed(item: ItemCountry) -> void:
	_set_setting_no_signal(item, _on_item_country_changed, army.owner_country)


func _on_army_size_changed(item: ItemInt) -> void:
	_set_setting_no_signal(item, _on_item_size_changed, army.size().value)


func _on_army_movements_changed(item: ItemInt) -> void:
	_set_setting_no_signal(item, _on_item_moves_changed, army.movements_made())
