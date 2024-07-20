class_name RelationshipInfoNode
extends Control


var country_1: Country:
	set(value):
		country_1 = value
		_refresh()

var country_2: Country:
	set(value):
		country_2 = value
		_refresh()

## The information on how country_1 behaves
## in relation with country_2, as a string.
var info_text_1_to_2: String = "":
	set(value):
		info_text_1_to_2 = value
		_refresh_label_1_to_2()

## The information on how country_2 behaves
## in relation with country_1, as a string.
var info_text_2_to_1: String = "":
	set(value):
		info_text_2_to_1 = value
		_refresh_label_2_to_1()

## The color with which to show the given text.
var info_color_1_to_2 := Color.WHITE:
	set(value):
		info_color_1_to_2 = value
		_refresh_label_1_to_2()

## The color with which to show the given text.
var info_color_2_to_1 := Color.WHITE:
	set(value):
		info_color_2_to_1 = value
		_refresh_label_2_to_1()

@onready var _country_1_node := %Country1 as CountryButton
@onready var _country_2_node := %Country2 as CountryButton
@onready var _label_1_to_2 := %Label1To2 as Label
@onready var _label_2_to_1 := %Label2To1 as Label


func _ready() -> void:
	_refresh()
	_refresh_label_1_to_2()
	_refresh_label_2_to_1()


func _refresh() -> void:
	if not is_node_ready():
		return
	
	if country_1 == null or country_2 == null:
		hide()
		return
	
	_country_1_node.country = country_1
	_country_2_node.country = country_2
	
	show()


func _refresh_label_1_to_2() -> void:
	if not is_node_ready():
		return
	
	_label_1_to_2.add_theme_color_override("font_color", info_color_1_to_2)
	_label_1_to_2.text = info_text_1_to_2


func _refresh_label_2_to_1() -> void:
	if not is_node_ready():
		return
	
	_label_2_to_1.add_theme_color_override("font_color", info_color_2_to_1)
	_label_2_to_1.text = info_text_2_to_1
