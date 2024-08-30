class_name GameWorld
## Base class for a [Game]'s world.
##
## Extend this class to provide more features, i.e. a 2D map, a 3D map, etc.


var armies := Armies.new():
	set(value):
		armies = value
		
		_battle_detection = BattleDetection.new()
		armies.army_added.connect(_battle_detection._on_army_added)

var provinces := Provinces.new()

var _battle_detection := BattleDetection.new()


# Because the setter isn't called during initialization
func _init() -> void:
	armies.army_added.connect(_battle_detection._on_army_added)
