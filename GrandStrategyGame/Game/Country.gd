class_name Country
extends Node


@export var country_name: String = "(Unnamed Country)"
@export var color: Color = Color.DARK_GRAY

var _key: String


func key() -> String:
	return _key
