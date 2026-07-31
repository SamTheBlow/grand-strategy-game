class_name InterfaceArmyEdit
extends AppEditorInterface
## The interface in which the user can edit given [Army].

signal closed()
signal delete_pressed(army: Army)
signal duplicate_pressed(army: Army)
signal texture_popup_requested(item_texture: ItemTexture)
signal country_select_pressed(item_country: ItemCountry)

var army: Army
var playing_country: PlayingCountry

## This interface automatically closes
## if its army is removed from this armies list.
## May be null, in which case this feature is not used.
var armies: Armies = null:
	set(value):
		if armies != null:
			armies.removed.disconnect(_on_army_removed)

		armies = value

		if armies != null:
			armies.removed.connect(_on_army_removed)

@onready var _preview := %ArmyPreview as ArmyPreviewNode
@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	_preview.setup(army, playing_country)

	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_load_settings()
	_settings.refresh()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"delete"):
		delete_pressed.emit(army)
	if Input.is_action_just_pressed(&"duplicate"):
		duplicate_pressed.emit(army)


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
	item_texture.popup_requested.connect(texture_popup_requested.emit)
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


func _apply_undo_redo_action(
		description: String,
		object: Object,
		property_name: StringName,
		old_value: Variant,
		new_value: Variant
) -> void:
	undo_redo.create_action(description)
	undo_redo.add_do_property(object, property_name, new_value)
	undo_redo.add_undo_property(object, property_name, old_value)
	undo_redo.commit_action()


func _on_back_button_pressed() -> void:
	closed.emit()


func _on_army_removed(army_removed: Army) -> void:
	if army_removed == army:
		closed.emit()


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(army)


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
