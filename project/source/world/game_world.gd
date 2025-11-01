class_name GameWorld
## A [Game]'s world.

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

var _limits := WorldLimits.new(self)


func _init(game: Game) -> void:
	armies_of_each_country = ArmiesOfEachCountry.new(game.countries, armies)
	provinces_of_each_country = (
			ProvincesOfEachCountry.new(game.countries, provinces)
	)


func set_background_color(value: Color) -> void:
	background_color = value


func limits() -> WorldLimits:
	return _limits
