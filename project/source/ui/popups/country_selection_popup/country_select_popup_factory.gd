extends Node
## Creates a [CountrySelectPopup] when the user wants to select a country.

signal popup_created(contents: Node)

const _POPUP_CONTENTS_SCENE: PackedScene = preload("uid://gfcp3xbnck52")

@export var _world_visuals: WorldVisuals2D


func create_popup(item_country: ItemCountry) -> void:
	var popup := _POPUP_CONTENTS_SCENE.instantiate() as CountrySelectPopup
	popup.setup(
			_world_visuals.project.game.countries, item_country.may_be_null()
	)
	popup.country_selected.connect(item_country.set_value)
	popup_created.emit(popup)
