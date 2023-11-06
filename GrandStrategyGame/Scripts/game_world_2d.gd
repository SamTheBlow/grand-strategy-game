class_name GameWorld2D
extends GameWorld


var camera_limit_x: int = 10_000_000
var camera_limit_y: int = 10_000_000
var background: WorldBackground


## Meant to be called right after instantiating the scene
func init() -> void:
	name = "World"
	background = $Node2D/Background as WorldBackground
	provinces = $Node2D/Provinces as Provinces
	
	background.connect("clicked", Callable(provinces, "deselect_province"))


func as_JSON() -> Dictionary:
	return {
		"camera_limit_x": camera_limit_x,
		"camera_limit_y": camera_limit_y,
		"provinces": provinces.as_JSON(),
	}
