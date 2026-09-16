extends Node
## Creates a [PlayerSelectPopup] when the user wants to select a [GamePlayer].

signal popup_created(contents: Node)

const _POPUP_CONTENTS_SCENE: PackedScene = preload("uid://c1rlaool50wdd")

@export var _world_visuals: WorldVisuals2D


## Creates a popup and calls given [Callable] when a player is selected.
## The callable must take an argument of type [GamePlayer].
func create_popup(callable: Callable) -> void:
	var popup := _POPUP_CONTENTS_SCENE.instantiate() as PlayerSelectPopup
	popup.setup(_world_visuals.project.game.game_players)
	popup.player_selected.connect(callable)
	popup_created.emit(popup)
