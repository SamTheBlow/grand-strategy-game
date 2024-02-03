class_name GameWorld
extends Node


signal province_selected(province: Province)

var provinces: Provinces


func connect_to_provinces(callable: Callable) -> void:
	provinces.connect_to_provinces(callable)
