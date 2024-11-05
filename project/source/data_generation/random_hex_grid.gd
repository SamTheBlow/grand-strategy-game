class_name RandomHexGrid
## Takes given JSON data and populates it with a valid hex grid map,
## adds in some countries and places those countries on the map.


var grid_width: int = 1
var grid_height: int = 1
var number_of_countries: int = 2


func apply(raw_data: Dictionary) -> void:
	HexGridGeneration.new().apply(raw_data, grid_width, grid_height)
	CountryGeneration.new().apply(raw_data, number_of_countries)
	CountryPlacementGeneration.new().apply(raw_data)
