@tool
class_name PropertyTreeNode
extends MarginContainer
## Base class. Displays the information contained in a [PropertyTreeItem].
## Displays the item's children recursively with indentation.
## All child items have the same spacing and tabbing as this item.

## Press this button to refresh this node's visuals in the editor,
## to reflect changes you've made to this item or one of its children.
@warning_ignore("unused_private_class_variable")
@export_tool_button("Refresh") var _refresh_function: Callable = refresh

## The number of pixels between each item node.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var spacing_px: int = 8
## The number of pixels for each tab.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var tabbing_px: int = 32

## Child item nodes are stored here for easy access.
var _child_item_nodes: Array[PropertyTreeNode] = []

# Preloading these would be nice, but, because the scene's
# root node extends this very class, it leads to errors. (I think?)
var _item_int_scene := load("uid://cummjubuua6yk") as PackedScene
var _item_float_scene := load("uid://dd0mqtbyhpwcg") as PackedScene
var _item_bool_scene := load("uid://bo8oke3mld227") as PackedScene
var _item_string_scene := load("uid://cemtdca5rfqlk") as PackedScene
var _item_options_scene := load("uid://bh8aukwuigg4e") as PackedScene
var _item_range_int_scene := load("uid://liwg6fdq6hr5") as PackedScene
var _item_range_float_scene := load("uid://diptsnmuse4kn") as PackedScene
var _item_color_scene := load("uid://bm83m86biyiv2") as PackedScene
var _item_vector2_scene := load("uid://dp622gh87xpkt") as PackedScene
var _item_texture_scene := load("uid://ccq7n0x7mov6s") as PackedScene
var _item_country_scene := load("uid://bmfl2xa7n2g2n") as PackedScene
var _item_void_scene := load("uid://cintikjibl1vr") as PackedScene

@onready var _container := %Container as VBoxContainer


## Refreshes the visual contents. You should call this after modifying
## the data inside either this node's item or one of its children.
func refresh() -> void:
	if not is_node_ready() or _item() == null:
		return
	_clear()
	_add_child_items(_item().child_items)


## Returns this node's item. May be null.
func _item() -> PropertyTreeItem:
	return null


## Removes all child item nodes.
func _clear() -> void:
	if _container == null:
		return

	for child_item_node in _child_item_nodes:
		_container.remove_child(child_item_node)
		child_item_node.queue_free()

	_child_item_nodes = []


func _add_child_items(
		child_items: Array[PropertyTreeItem],
		with_spacing: bool = true,
		with_tabbing: bool = true
) -> void:
	for child_item in child_items:
		if child_item is ItemInt:
			var item_node := _item_int_scene.instantiate() as ItemIntNode
			item_node.item = child_item as ItemInt
			_add_item(item_node, with_spacing, with_tabbing)
		elif child_item is ItemFloat:
			var item_node := _item_float_scene.instantiate() as ItemFloatNode
			item_node.item = child_item as ItemFloat
			_add_item(item_node, with_spacing, with_tabbing)
		elif child_item is ItemBool:
			var item_node := _item_bool_scene.instantiate() as ItemBoolNode
			item_node.item = child_item as ItemBool
			_add_item(item_node, with_spacing, with_tabbing)
		elif child_item is ItemString:
			var item_node := _item_string_scene.instantiate() as ItemStringNode
			item_node.item = child_item as ItemString
			_add_item(item_node, with_spacing, with_tabbing)
		elif child_item is ItemOptions:
			var item_node := (
					_item_options_scene.instantiate() as ItemOptionsNode
			)
			item_node.item = child_item as ItemOptions
			_add_item(item_node, with_spacing, with_tabbing)
		elif child_item is ItemRangeInt:
			var item_node := (
					_item_range_int_scene.instantiate() as ItemRangeIntNode
			)
			item_node.item = child_item as ItemRangeInt
			_add_item(item_node, with_spacing, with_tabbing)
		elif child_item is ItemRangeFloat:
			var item_node := (
					_item_range_float_scene.instantiate() as ItemRangeFloatNode
			)
			item_node.item = child_item as ItemRangeFloat
			_add_item(item_node, with_spacing, with_tabbing)
		elif child_item is ItemColor:
			var item_node := _item_color_scene.instantiate() as ItemColorNode
			item_node.item = child_item as ItemColor
			_add_item(item_node, with_spacing, with_tabbing)
		elif child_item is ItemVector2:
			var item_node := (
					_item_vector2_scene.instantiate() as ItemVector2Node
			)
			item_node.item = child_item as ItemVector2
			_add_item(item_node, with_spacing, with_tabbing)
		elif child_item is ItemTexture:
			var item_node := (
					_item_texture_scene.instantiate() as ItemTextureNode
			)
			item_node.item = child_item as ItemTexture
			_add_item(item_node, with_spacing, with_tabbing)
		elif child_item is ItemCountry:
			var item_node := (
					_item_country_scene.instantiate() as ItemCountryNode
			)
			item_node.item = child_item as ItemCountry
			_add_item(item_node, with_spacing, with_tabbing)
		else:
			var item_node := _item_void_scene.instantiate() as ItemVoidNode
			item_node.item = child_item
			_add_item(item_node, with_spacing, with_tabbing)


func _add_item(
		item_node: PropertyTreeNode,
		with_spacing: bool = true,
		with_tabbing: bool = true
) -> void:
	item_node.spacing_px = spacing_px
	item_node.tabbing_px = tabbing_px

	_container.add_theme_constant_override(
			&"separation", spacing_px if with_spacing else 0
	)
	item_node.add_theme_constant_override(
			&"margin_left", tabbing_px if with_tabbing else 0
	)

	_container.add_child(item_node)
	_child_item_nodes.append(item_node)
