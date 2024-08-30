class_name GameWorld2D
extends GameWorld
## A [GameWorld] as a 2D map.


var limits := WorldLimits.new()
var background: WorldBackground

@onready var province_visuals := %Provinces as ProvinceVisualsContainer2D


func _ready() -> void:
	province_selection = %ProvinceSelection as ProvinceSelection


## Meant to be called right after instantiating the scene
func init(game: Game) -> void:
	(%AutoArrowInput as AutoArrowInput).game = game
	(%AutoArrowSync as AutoArrowSync).game = game
	background = %Background as WorldBackground
	(%AutoArrows as AutoArrowContainer).game = game
