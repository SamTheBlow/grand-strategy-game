class_name InterfaceProvinceEdit
extends AppEditorInterface
## The interface in which the user can edit given [Province].

var province: Province


func _ready() -> void:
	(%ProvincePreview as ProvincePreviewNode).setup(province)

	_setup_settings(%Settings as ItemVoidNode)

	closed.connect(navigator.open_new_interface.bind(
			InterfaceNavigator.Type.PROVINCE_LIST
	))


func _load_settings(settings_item: PropertyTreeItem) -> void:
	# Name
	var item_name := settings_item.child_items[0] as ItemString
	item_name.value = province.name
	item_name.placeholder_text = province.default_name()
	item_name.value_changed.connect(_on_name_value_changed)
	province.name_changed.connect(
			_on_province_name_changed.bind(item_name).unbind(1)
	)

	# Owner country
	var item_country := settings_item.child_items[3] as ItemCountry
	item_country.value = province.owner_country
	item_country.value_changed.connect(_on_country_value_changed)
	item_country.change_requested.connect(country_select_pressed.emit)
	province.owner_changed.connect(
			_on_province_owner_changed.bind(item_country).unbind(1)
	)

	# Population
	var item_population := settings_item.child_items[4] as ItemInt
	item_population.value = province.population().value
	item_population.value_changed.connect(_on_population_value_changed)
	province.population().value_changed.connect(
			_on_province_population_changed.bind(item_population).unbind(1)
	)

	# Money income
	var item_income := settings_item.child_items[5] as ItemInt
	item_income.value = province.base_money_income().value
	item_income.value_changed.connect(_on_income_value_changed)
	province.base_money_income().value_changed.connect(
			_on_province_income_changed.bind(item_income).unbind(1)
	)

	# Has fortress
	var item_fortress := settings_item.child_items[6] as ItemBool
	item_fortress.value = (
			province.buildings.number_of_type(Building.Type.FORTRESS) > 0
	)
	item_fortress.value_changed.connect(_on_has_fortress_value_changed)
	province.buildings.changed.connect(
			_on_province_buildings_changed.bind(item_fortress)
	)


func _on_province_removed(province_removed: Province) -> void:
	if province_removed == province:
		closed.emit()


func _delete() -> void:
	project.game.world.provinces.undo_redo_remove(
			province,
			undo_redo,
			project.game.world.armies,
			project.game.world.armies_in_each_province
	)


func _duplicate() -> void:
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

	# Select the new province for editing
	province_select_requested.emit(new_province)


func _on_name_value_changed(item: ItemString) -> void:
	_apply_undo_redo_property(
			"Change province name",
			province,
			&"name",
			province.name,
			item.value
	)


func _on_country_value_changed(item: ItemCountry) -> void:
	_apply_undo_redo_property(
			"Change province owner",
			province,
			&"owner_country",
			province.owner_country,
			item.value
	)


func _on_population_value_changed(item: ItemInt) -> void:
	_apply_undo_redo_property(
			"Change province population",
			province.population(),
			&"value",
			province.population().value,
			item.value
	)


func _on_income_value_changed(item: ItemInt) -> void:
	_apply_undo_redo_property(
			"Change province money income",
			province.base_money_income(),
			&"value",
			province.base_money_income().value,
			item.value
	)


func _on_has_fortress_value_changed(item: ItemBool) -> void:
	var description: String = "Toggle province having a fortress"

	var do_callable: Callable
	var undo_callable: Callable
	if item.value:
		# Add fortress
		var new_fortress := Fortress.new(province.id)
		do_callable = province.buildings.add.bind(new_fortress)
		undo_callable = province.buildings.remove.bind(new_fortress)
	else:
		# Remove fortress
		var existing_fortress: Building = province.buildings._list[0]
		do_callable = province.buildings.remove.bind(existing_fortress)
		undo_callable = province.buildings.add.bind(existing_fortress)

	_apply_undo_redo_method(description, do_callable, undo_callable)


func _on_province_name_changed(item: ItemString) -> void:
	_set_setting_no_signal(item, _on_name_value_changed, province.name)


func _on_province_owner_changed(item: ItemCountry) -> void:
	_set_setting_no_signal(
			item, _on_country_value_changed, province.owner_country
	)


func _on_province_population_changed(item: ItemInt) -> void:
	_set_setting_no_signal(
			item, _on_population_value_changed, province.population().value
	)


func _on_province_income_changed(item: ItemInt) -> void:
	_set_setting_no_signal(
			item, _on_income_value_changed, province.base_money_income().value
	)


func _on_province_buildings_changed(item: ItemBool) -> void:
	_set_setting_no_signal(
			item,
			_on_has_fortress_value_changed,
			province.buildings.number_of_type(Building.Type.FORTRESS) > 0
	)
