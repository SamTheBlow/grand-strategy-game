class_name GameWorld
extends Node


signal province_selected(province: Province)

var provinces: Provinces


func connect_to_provinces(callable: Callable) -> void:
	provinces.connect_to_provinces(callable)


func as_JSON() -> Dictionary:
	return {
		"provinces": provinces.as_JSON(),
	}
