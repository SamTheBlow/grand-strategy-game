class_name InterfaceProvinceEdit
extends AppEditorInterface
## The interface in which the user can edit given [Province].

signal back_pressed()
signal delete_pressed(province: Province)
signal duplicate_pressed(province: Province)
signal change_owner_pressed(province: Province)

var province := Province.new()

@onready var _preview := %ProvincePreview as ProvincePreviewNode
@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_settings.refresh()

	_load_settings()
	_preview.setup(province)
	province.owner_changed.connect(_on_owner_country_changed)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"delete"):
		delete_pressed.emit(province)
	if Input.is_action_just_pressed(&"duplicate"):
		duplicate_pressed.emit(province)


func _load_settings() -> void:
	# Name
	(_settings.item.child_items[0] as ItemString).value = province.name
	(_settings.item.child_items[0] as ItemString).placeholder_text = (
			province.default_name()
	)
	(_settings.item.child_items[0] as ItemString).value_changed.connect(
			_on_name_value_changed
	)

	# Owner country
	(_settings.item.child_items[3] as ItemCountry).value = (
			province.owner_country
	)
	(_settings.item.child_items[3] as ItemCountry).value_changed.connect(
			_on_item_country_changed
	)
	(_settings.item.child_items[3] as ItemCountry).change_requested.connect(
			change_owner_pressed.emit.bind(province)
	)

	# Population
	(_settings.item.child_items[4] as ItemInt).value = (
			province.population().value
	)
	(_settings.item.child_items[4] as ItemInt).value_changed.connect(
			_on_population_value_changed
	)

	# Money income
	(_settings.item.child_items[5] as ItemInt).value = (
			province.base_money_income().value
	)
	(_settings.item.child_items[5] as ItemInt).value_changed.connect(
			_on_income_value_changed
	)

	# Has fortress
	(_settings.item.child_items[6] as ItemBool).value = (
			province.buildings.number_of_type(Building.Type.FORTRESS) > 0
	)
	(_settings.item.child_items[6] as ItemBool).value_changed.connect(
			_on_has_fortress_value_changed
	)


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(province)


func _on_name_value_changed(item: ItemString) -> void:
	province.name = item.value


func _on_item_country_changed(item: ItemCountry) -> void:
	province.owner_country = item.value


func _on_population_value_changed(item: ItemInt) -> void:
	province.population().value = item.value


func _on_income_value_changed(item: ItemInt) -> void:
	province.base_money_income().value = item.value


func _on_has_fortress_value_changed(item: ItemBool) -> void:
	if item.value:
		province.buildings.add(Fortress.new(province.id))
	else:
		province.buildings.remove(province.buildings._list[0])


func _on_owner_country_changed(_province: Province) -> void:
	(_settings.item.child_items[3] as ItemCountry).value = (
			province.owner_country
	)
