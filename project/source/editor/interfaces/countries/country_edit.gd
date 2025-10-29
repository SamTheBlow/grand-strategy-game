class_name InterfaceCountryEdit
extends AppEditorInterface
## The interface in which the user can edit given [Country].

signal back_pressed()
signal delete_pressed(country: Country)
signal duplicate_pressed(country: Country)

var country := Country.new()

@onready var _preview := %CountryIcon as ColorRect
@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_settings.refresh()

	_load_settings()
	_preview.color = country.color


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"delete"):
		delete_pressed.emit(country)
	if Input.is_action_just_pressed(&"duplicate"):
		duplicate_pressed.emit(country)


func _load_settings() -> void:
	pass


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(country)
