class_name GameWorld
## Base class for a [Game]'s world.
##
## Extend this class to provide more features, i.e. a 2D map, a 3D map, etc.

## Do not overwrite!
var armies := Armies.new()
## Do not overwrite!
var provinces := Provinces.new()

var armies_in_each_province := ArmiesInEachProvince.new(provinces, armies)
var armies_of_each_country: ArmiesOfEachCountry
var provinces_of_each_country: ProvincesOfEachCountry


func _init(game: Game) -> void:
	armies_of_each_country = ArmiesOfEachCountry.new(game.countries, armies)
	provinces_of_each_country = (
			ProvincesOfEachCountry.new(game.countries, provinces)
	)
