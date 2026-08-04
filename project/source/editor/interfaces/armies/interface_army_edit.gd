class_name InterfaceArmyEdit
extends AppEditorInterface
## The interface in which the user can edit given [Army].

var army: Army

@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	(%ArmyPreview as ArmyPreviewNode).setup(
			army, PlayingCountry.new(project.game)
	)

	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_load_settings()
	_settings.refresh()

	project.game.world.armies.removed.connect(_on_army_removed)

	closed.connect(navigator.open_new_interface.bind(
			InterfaceNavigator.InterfaceType.ARMY_LIST,
			project,
			editor_settings
	))


func _unhandled_input(event: InputEvent) -> void:
	super(event)

	if event.is_action_pressed(&"delete"):
		_delete_army()
	if event.is_action_pressed(&"duplicate"):
		_duplicate_army()


func _setting_texture() -> ItemTexture:
	return _settings.item.child_items[0] as ItemTexture


func _setting_country() -> ItemCountry:
	return _settings.item.child_items[1] as ItemCountry


func _setting_army_size() -> ItemInt:
	return _settings.item.child_items[2] as ItemInt


func _setting_movements() -> ItemInt:
	return _settings.item.child_items[3] as ItemInt


func _load_settings() -> void:
	# Texture
	var item_texture: ItemTexture = _setting_texture()
	item_texture.fallback_texture = ArmyVisuals2D.DEFAULT_TEXTURE
	item_texture.value = army.texture
	item_texture.value_changed.connect(_on_item_texture_changed)
	item_texture.popup_requested.connect(
			texture_popup_requested.emit.bind(project.textures)
	)
	army.texture_changed.connect(_on_army_texture_changed)

	# Owner country
	_setting_country().make_unnullable(army.owner_country)
	_setting_country().value_changed.connect(_on_item_country_changed)
	_setting_country().change_requested.connect(country_select_pressed.emit)
	army.allegiance_changed.connect(_on_army_owner_changed)

	# Army size
	_setting_army_size().has_minimum = true
	_setting_army_size().minimum = army.size().minimum_value
	_setting_army_size().has_maximum = army.size().has_maximum()
	_setting_army_size().maximum = army.size().maximum_value
	_setting_army_size().value = army.size().value
	_setting_army_size().value_changed.connect(_on_item_size_changed)
	army.size().changed.connect(_on_army_size_changed)

	# Movements made
	_setting_movements().has_minimum = true
	_setting_movements().minimum = 0
	_setting_movements().value = army.movements_made()
	_setting_movements().value_changed.connect(_on_item_movements_changed)
	army.movements_made_changed.connect(_on_army_movements_changed)


func _delete_army() -> void:
	project.game.world.armies.undo_redo_remove(
			army, undo_redo, project.game.world.armies_in_each_province
	)


func _duplicate_army() -> void:
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


func _on_back_button_pressed() -> void:
	closed.emit()


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
	if army.owner_country == item.value:
		return

	_apply_undo_redo_action(
			"Change army allegiance",
			army,
			&"owner_country",
			army.owner_country,
			item.value
	)


func _on_item_size_changed(item: ItemInt) -> void:
	if army.size().value == item.value:
		return

	_apply_undo_redo_action(
			"Change army size",
			army.size(),
			&"value",
			army.size().value,
			item.value
	)


func _on_item_movements_changed(item: ItemInt) -> void:
	if army.movements_made() == item.value:
		return

	_apply_undo_redo_action(
			"Change army movements made",
			army,
			&"_movements_made",
			army.movements_made(),
			item.value
	)


func _on_army_texture_changed() -> void:
	_setting_texture().value_changed.disconnect(_on_item_texture_changed)
	_setting_texture().value = army.texture
	_setting_texture().value_changed.connect(_on_item_texture_changed)


func _on_army_owner_changed(_country: Country) -> void:
	_setting_country().value_changed.disconnect(_on_item_country_changed)
	_setting_country().value = army.owner_country
	_setting_country().value_changed.connect(_on_item_country_changed)


func _on_army_size_changed(_new_value: int) -> void:
	_setting_army_size().value_changed.disconnect(_on_item_size_changed)
	_setting_army_size().value = army.size().value
	_setting_army_size().value_changed.connect(_on_item_size_changed)


func _on_army_movements_changed(_movements: int) -> void:
	_setting_movements().value_changed.disconnect(_on_item_movements_changed)
	_setting_movements().value = army.movements_made()
	_setting_movements().value_changed.connect(_on_item_movements_changed)
