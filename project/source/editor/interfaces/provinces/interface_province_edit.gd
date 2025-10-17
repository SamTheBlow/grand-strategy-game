class_name InterfaceProvinceEdit
extends AppEditorInterface
## The interface in which the user can edit given [Province].

signal back_pressed()
signal delete_pressed(province: Province)
signal duplicate_pressed(province: Province)

var province := Province.new()

@onready var _preview_rect := %PreviewRect as TextureRect
@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_settings.refresh()

	_load_settings()
	_update_preview()

	# Name
	(_settings.item.child_items[0] as ItemString).value_changed.connect(
			_on_name_value_changed
	)
	# Position
	(_settings.item.child_items[1] as ItemVector2).value_changed.connect(
			_on_position_value_changed
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
	(_settings.item.child_items[1] as ItemVector2).set_data(province.position)


func _update_preview() -> void:
	# TODO apply preview
	pass


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(province)


func _on_name_value_changed(item: ItemString) -> void:
	province.name = item.value


func _on_position_value_changed(item: ItemVector2) -> void:
	province.position = item.get_data()
