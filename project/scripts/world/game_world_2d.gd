class_name GameWorld2D
extends GameWorld
## A [GameWorld] as a 2D map.


var limits := WorldLimits.new()
var background: WorldBackground
var auto_arrow_container: AutoArrowContainer


## Meant to be called right after instantiating the scene
func init(game: Game) -> void:
	name = "World"
	background = %Background as WorldBackground
	provinces = %Provinces as Provinces
	auto_arrow_container = %AutoArrowContainer as AutoArrowContainer
	auto_arrow_container.game = game
	
	background.clicked.connect(provinces.deselect_province)
