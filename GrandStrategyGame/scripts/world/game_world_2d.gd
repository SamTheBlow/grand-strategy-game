class_name GameWorld2D
extends GameWorld


var limits: WorldLimits
var background: WorldBackground


## Meant to be called right after instantiating the scene
func init() -> void:
	name = "World"
	background = $Node2D/Background as WorldBackground
	provinces = $Node2D/Provinces as Provinces
	
	background.clicked.connect(provinces.deselect_province)


func as_json() -> Dictionary:
	return {
		"limits": limits.as_json(),
		"provinces": provinces.as_json(),
	}
