class_name GameWorld
extends Node
## Base class for a [Game]'s world.
##
## Extend this class to provide more features, i.e. a 2D map, a 3D map, etc.


var battle_detection := BattleDetection.new()
var armies: Armies:
	set(value):
		armies = value
		armies.army_added.connect(battle_detection._on_army_added)
var provinces: Provinces
