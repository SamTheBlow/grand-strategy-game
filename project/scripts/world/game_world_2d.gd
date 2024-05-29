class_name GameWorld2D
extends GameWorld
## A [GameWorld] as a 2D map.


var limits := WorldLimits.new()
var background: WorldBackground


## Meant to be called right after instantiating the scene
func init() -> void:
	name = "World"
	background = $Node2D/Background as WorldBackground
	provinces = $Node2D/Provinces as Provinces
	
	background.clicked.connect(provinces.deselect_province)
