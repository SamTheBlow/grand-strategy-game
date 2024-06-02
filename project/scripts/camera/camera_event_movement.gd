class_name CameraEventMovement
extends Node
## Responsible for moving the camera under certain events.
##
## Initially, moves the camera to the center of the world map.
## When it's a new player's turn to play (see [GameTurn]), this node moves
## the camera to one of the [Country]'s controlled provinces.
## If their [Country] doesn't have control over any [Province],
## or if the player is a spectator, it defaults to not moving.


@export var _game: Game
@export var _camera: CustomCamera2D


func _ready() -> void:
	_camera.move_to(_camera.world_limits._limits.get_center())
	_game.turn.player_changed.connect(_on_turn_player_changed)
	_on_turn_player_changed(_game.turn.playing_player())


func _on_turn_player_changed(player: GamePlayer) -> void:
	var country: Country = player.playing_country
	if not country:
		return
	
	var target_province: Province
	for province in _game.world.provinces.list():
		if province.owner_country and province.owner_country == country:
			target_province = province
			break
	
	if target_province:
		_camera.move_to(target_province.position_army_host)
