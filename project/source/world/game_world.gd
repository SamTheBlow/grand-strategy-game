class_name GameWorld
## Base class for a [Game]'s world.
##
## Extend this class to provide more features, i.e. a 2D map, a 3D map, etc.

signal background_color_changed(new_color: Color)

## Do not overwrite!
var armies := Armies.new()
## Do not overwrite!
var provinces := Provinces.new()

var background_color: Color = BackgroundColor.default_clear_color():
	set(value):
		if background_color == value:
			return
		background_color = value
		background_color_changed.emit(background_color)

var decorations := WorldDecorations.new()

var armies_in_each_province := ArmiesInEachProvince.new(provinces, armies)
var armies_of_each_country: ArmiesOfEachCountry
var provinces_of_each_country: ProvincesOfEachCountry


func _init(game: Game) -> void:
	armies_of_each_country = ArmiesOfEachCountry.new(game.countries, armies)
	provinces_of_each_country = (
			ProvincesOfEachCountry.new(game.countries, provinces)
	)
