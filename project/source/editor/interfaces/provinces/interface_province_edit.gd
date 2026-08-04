class_name InterfaceProvinceEdit
extends AppEditorInterface
## The interface in which the user can edit given [Province].

var province: Province

@onready var _preview := %ProvincePreview as ProvincePreviewNode
@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	_preview.setup(province)

	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_load_settings()
	_settings.refresh()

	closed.connect(navigator.open_new_interface.bind(
			InterfaceNavigator.InterfaceType.PROVINCE_LIST,
			project,
			editor_settings
	))


func _unhandled_input(event: InputEvent) -> void:
	super(event)

	if event.is_action_pressed(&"delete"):
		_delete_province()
	if event.is_action_pressed(&"duplicate"):
		_duplicate_province()


func _setting_province_name() -> ItemString:
	return _settings.item.child_items[0] as ItemString


func _setting_country() -> ItemCountry:
	return _settings.item.child_items[3] as ItemCountry


func _setting_population() -> ItemInt:
	return _settings.item.child_items[4] as ItemInt


func _setting_income() -> ItemInt:
	return _settings.item.child_items[5] as ItemInt


func _setting_fortress() -> ItemBool:
	return _settings.item.child_items[6] as ItemBool


func _load_settings() -> void:
	# Name
	_setting_province_name().value = province.name
	_setting_province_name().placeholder_text = province.default_name()
	_setting_province_name().value_changed.connect(_on_name_value_changed)
	province.name_changed.connect(_on_province_name_changed)

	# Owner country
	_setting_country().value = province.owner_country
	_setting_country().value_changed.connect(_on_country_value_changed)
	_setting_country().change_requested.connect(country_select_pressed.emit)
	province.owner_changed.connect(_on_province_owner_changed)

	# Population
	_setting_population().value = province.population().value
	_setting_population().value_changed.connect(_on_population_value_changed)
	province.population().value_changed.connect(
			_on_province_population_changed
	)

	# Money income
	_setting_income().value = province.base_money_income().value
	_setting_income().value_changed.connect(_on_income_value_changed)
	province.base_money_income().value_changed.connect(
			_on_province_income_changed
	)

	# Has fortress
	_setting_fortress().value = (
			province.buildings.number_of_type(Building.Type.FORTRESS) > 0
	)
	_setting_fortress().value_changed.connect(_on_has_fortress_value_changed)
	province.buildings.changed.connect(_on_province_buildings_changed)


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


func _on_province_removed(province_removed: Province) -> void:
	if province_removed == province:
		closed.emit()


func _delete_province() -> void:
	project.game.world.provinces.undo_redo_remove(
			province,
			undo_redo,
			project.game.world.armies,
			project.game.world.armies_in_each_province
	)


func _duplicate_province() -> void:
	const _DUPLICATE_PROVINCE_OFFSET = Vector2(64.0, 64.0)

	# Create duplicate
	var new_province := Province.new()
	new_province.polygon().array = province.polygon().array.duplicate()
	new_province.position_army_host = province.position_army_host
	new_province.position_fortress = province.position_fortress
	new_province.move_relative(_DUPLICATE_PROVINCE_OFFSET)
	new_province.owner_country = province.owner_country
	new_province.population().value = province.population().value
	new_province.base_money_income().value = province.base_money_income().value

	for building in province.buildings.list():
		new_province.buildings.add(Fortress.new(province.id))

	# We need this new province to have a new unique id
	# assigned to it before we can create the undo_redo action
	project.game.world.provinces.add(new_province)

	# Create undo_redo action
	# (don't execute it since we already added the province)
	undo_redo.create_action("Duplicate province")
	undo_redo.add_do_method(
			project.game.world.provinces.add.bind(new_province)
	)
	undo_redo.add_undo_method(
			project.game.world.provinces.remove.bind(new_province.id)
	)
	undo_redo.commit_action(false)

	# Open interface to edit the new province
	navigator.open_province_edit_interface(
			new_province.id, project, editor_settings
	)


func _on_name_value_changed(item: ItemString) -> void:
	if province.name == item.value:
		return

	_apply_undo_redo_action(
			"Change province name",
			province,
			&"name",
			province.name,
			item.value
	)


func _on_country_value_changed(item: ItemCountry) -> void:
	if province.owner_country == item.value:
		return

	_apply_undo_redo_action(
			"Change province owner",
			province,
			&"owner_country",
			province.owner_country,
			item.value
	)


func _on_population_value_changed(item: ItemInt) -> void:
	if province.population().value == item.value:
		return

	_apply_undo_redo_action(
			"Change province population",
			province.population(),
			&"value",
			province.population().value,
			item.value
	)


func _on_income_value_changed(item: ItemInt) -> void:
	if province.base_money_income().value == item.value:
		return

	_apply_undo_redo_action(
			"Change province money income",
			province.base_money_income(),
			&"value",
			province.base_money_income().value,
			item.value
	)


func _on_has_fortress_value_changed(item: ItemBool) -> void:
	if (
		(province.buildings.number_of_type(Building.Type.FORTRESS) > 0)
		== item.value
	):
		return

	undo_redo.create_action("Toggle province having a fortress")
	if item.value:
		var new_fortress := Fortress.new(province.id)
		undo_redo.add_do_method(province.buildings.add.bind(new_fortress))
		undo_redo.add_undo_method(province.buildings.remove.bind(new_fortress))
	else:
		var existing_fortress: Building = province.buildings._list[0]
		undo_redo.add_do_method(
				province.buildings.remove.bind(existing_fortress)
		)
		undo_redo.add_undo_method(
				province.buildings.add.bind(existing_fortress)
		)
	undo_redo.commit_action()


func _on_province_name_changed(_new_name: String) -> void:
	_setting_province_name().value = province.name


func _on_province_owner_changed(_changed_province: Province) -> void:
	_setting_country().value = province.owner_country


func _on_province_population_changed(_new_value: int) -> void:
	_setting_population().value = province.population().value


func _on_province_income_changed(_new_value: int) -> void:
	_setting_income().value = province.base_money_income().value


func _on_province_buildings_changed() -> void:
	_setting_fortress().value = (
			province.buildings.number_of_type(Building.Type.FORTRESS) > 0
	)
