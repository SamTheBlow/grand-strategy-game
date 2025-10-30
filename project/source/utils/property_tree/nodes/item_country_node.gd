@tool
class_name ItemCountryNode
extends PropertyTreeNode
## A [PropertyTreeNode] that displays an [ItemCountry].

@export var item: ItemCountry

@onready var _label := %Label as Label
@onready var _country_info := %CountryInfo as CountryAndRelationship


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if item == null:
		push_error("Item is null.")
		return

	refresh()
	item.value_changed.connect(_on_country_changed)


func refresh() -> void:
	if not is_node_ready() or _item() == null:
		return
	super()

	_label.text = item.text
	_update_country_info()


func _update_country_info() -> void:
	_country_info.country = item.value


func _item() -> PropertyTreeItem:
	return item


func _on_change_button_pressed() -> void:
	item.request_change()


func _on_country_changed(_i: PropertyTreeItem) -> void:
	_update_country_info()
