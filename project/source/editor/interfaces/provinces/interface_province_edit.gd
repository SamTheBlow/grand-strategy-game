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


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(province)


func _on_name_value_changed(item: ItemString) -> void:
	province.name = item.value
