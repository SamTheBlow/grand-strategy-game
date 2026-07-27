class_name InterfaceTurnOrder
extends AppEditorInterface
## Editor interface for configuring the turn order.

const TURN_ORDER_ELEMENT_SCENE := preload("uid://dc67eps16xpfs") as PackedScene

var countries: Countries:
	set(value):
		if countries != null:
			countries.added.disconnect(_on_country_added)
			countries.removed.disconnect(_on_country_removed)
			countries.order_changed.disconnect(_on_country_order_changed)

		countries = value

		countries.added.connect(_on_country_added)
		countries.removed.connect(_on_country_removed)
		countries.order_changed.connect(_on_country_order_changed)

var item_random_turn_order := ItemBool.new()

var _country_nodes: Dictionary[int, EditorTurnOrderElement] = {}

## For the text that's displayed when the list is empty.
var _empty_list_label: Label

@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode
@onready var _info_label := %InfoLabel as Control
@onready var _list_container := %ListContainer as Control
@onready var _element_container := %ElementContainer as InterpolatedBoxContainer


func _ready() -> void:
	_element_container.drag_ended.connect(_on_drag_ended)

	_empty_list_label = Label.new()
	_empty_list_label.text = "(List is empty!)"
	_empty_list_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_list_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	item_random_turn_order.value_changed.connect(_on_item_value_changed)
	_update_visibility()
	_game_settings_node.item.child_items = [item_random_turn_order]
	_game_settings_node.refresh()

	_refresh_list()


func _update_visibility() -> void:
	_info_label.visible = item_random_turn_order.value
	_list_container.visible = not item_random_turn_order.value


func _refresh_list() -> void:
	NodeUtils.remove_all_children(_element_container)
	_country_nodes = {}

	_add_list_elements()


func _add_list_elements() -> void:
	if countries.size() == 0:
		_element_container.add_child(_empty_list_label)
		return

	for country in countries.list():
		_add_element(country)

	# Now that all the elements are in, refresh their arrows
	_refresh_arrows()


func _add_element(country: Country) -> void:
	var element := (
			TURN_ORDER_ELEMENT_SCENE.instantiate()
			as EditorTurnOrderElement
	)
	element.id = country.id
	element.label_text = country.name_or_default()
	element.up_pressed.connect(_on_element_up_pressed.bind(element))
	element.down_pressed.connect(_on_element_down_pressed.bind(element))
	_element_container.order_changed.connect(element.refresh_arrows)
	_element_container.add_child(element)
	_country_nodes[country.id] = element


func _remove_element(country: Country) -> void:
	NodeUtils.delete_node(_country_nodes[country.id])
	_country_nodes.erase(country.id)


func _refresh_arrows() -> void:
	for country_id in _country_nodes:
		_country_nodes[country_id].refresh_arrows()


func _reorder(country_id: int, new_index: int) -> void:
	var old_index: int = countries.position_of(country_id)

	if old_index == new_index:
		return

	undo_redo.create_action("Edit country order")
	undo_redo.add_do_method(countries.reorder.bind(country_id, new_index))
	undo_redo.add_undo_method(countries.reorder.bind(country_id, old_index))
	undo_redo.commit_action()


func _on_item_value_changed(_item: PropertyTreeItem) -> void:
	_update_visibility()

	var value: bool = item_random_turn_order.value
	undo_redo.create_action("Toggle random turn order")
	undo_redo.add_do_method(_on_toggle_changed.bind(value))
	undo_redo.add_undo_method(_on_toggle_changed.bind(not value))
	undo_redo.commit_action(false)


## Disconnects signals to avoid creating another undo_redo action
func _on_toggle_changed(value: bool) -> void:
	item_random_turn_order.value_changed.disconnect(_on_item_value_changed)
	item_random_turn_order.value = value
	_update_visibility()
	item_random_turn_order.value_changed.connect(_on_item_value_changed)


func _on_drag_ended(moved_node: Node) -> void:
	var element := moved_node as EditorTurnOrderElement
	_reorder(element.id, element.get_index())


func _on_element_up_pressed(element: EditorTurnOrderElement) -> void:
	_reorder(element.id, element.get_index() - 1)


func _on_element_down_pressed(element: EditorTurnOrderElement) -> void:
	_reorder(element.id, element.get_index() + 1)


func _on_country_added(country: Country) -> void:
	_add_element(country)
	_element_container.move_child(
			_country_nodes[country.id], countries.position_of(country.id)
	)
	_refresh_arrows()


func _on_country_removed(country: Country) -> void:
	_remove_element(country)
	_refresh_arrows()


## Moves element nodes to match country order
func _on_country_order_changed(
		country_id: int, _old_index: int, new_index: int
) -> void:
	_element_container.move_child(_country_nodes[country_id], new_index)
	_element_container.order_changed.emit()
