class_name GameWorld
## Base class for a [Game]'s world.
##
## Extend this class to provide more features, i.e. a 2D map, a 3D map, etc.


var armies := Armies.new()
var provinces := Provinces.new()

var armies_in_province := ArmiesInProvinceSystem.new(armies)
var provinces_of_countries := ProvincesOfCountries.new(provinces)
