class_name InterfaceProvinceEdit
extends AppEditorInterface
## The interface in which the user can edit given [Province].

signal back_pressed()
signal delete_pressed(province: Province)
signal duplicate_pressed(province: Province)

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

	# Name
	(_settings.item.child_items[0] as ItemString).value_changed.connect(
			_on_name_value_changed
	)

	# Population
	(_settings.item.child_items[3] as ItemInt).value_changed.connect(
			_on_population_value_changed
	)

	# Money income
	(_settings.item.child_items[4] as ItemInt).value_changed.connect(
			_on_income_value_changed
	)

	# Has fortress
	(_settings.item.child_items[5] as ItemBool).value_changed.connect(
			_on_has_fortress_value_changed
	)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"delete"):
		delete_pressed.emit(province)
	if Input.is_action_just_pressed(&"duplicate"):
		duplicate_pressed.emit(province)


func _load_settings() -> void:
	(_settings.item.child_items[0] as ItemString).value = province.name
	(_settings.item.child_items[0] as ItemString).placeholder_text = (
			province.default_name()
	)
	(_settings.item.child_items[3] as ItemInt).value = (
			province.population().value
	)
	(_settings.item.child_items[4] as ItemInt).value = (
			province.base_money_income().value
	)
	(_settings.item.child_items[5] as ItemBool).value = (
			province.buildings.number_of_type(Building.Type.FORTRESS) > 0
	)


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(province)


func _on_name_value_changed(item: ItemString) -> void:
	province.name = item.value


func _on_population_value_changed(item: ItemInt) -> void:
	province.population().value = item.value


func _on_income_value_changed(item: ItemInt) -> void:
	province.base_money_income().value = item.value


func _on_has_fortress_value_changed(item: ItemBool) -> void:
	if item.value:
		province.buildings.add(Fortress.new(province.id))
	else:
		province.buildings.remove(province.buildings._list[0])
