class_name CameraEventMovement
extends Node
## Responsible for moving the camera under certain events.
## These events can be enabled or disabled individually.


@export var _game: GameNode
@export var _camera: CustomCamera2D

## If true, after the game loads,
## the camera will start in the center of the world map.
@export var _start_in_center_of_map: bool = false

## If true, when it's a new player's turn to play (see [GameTurn]),
## moves the camera to one of the [Country]'s controlled provinces.
## If their [Country] doesn't have control over any [Province],
## or if the player is a spectator, it defaults to not moving.
@export var _move_to_playing_country: bool = false


func _ready() -> void:
	if _start_in_center_of_map:
		# Need to wait for the world limits to load
		if not _game.is_node_ready():
			await _game.ready
		
		# TODO bad code: private member access
		_camera.move_to(_camera.world_limits._limits.get_center())
	
	_game.game.turn.player_changed.connect(_on_turn_player_changed)
	_on_turn_player_changed(_game.game.turn.playing_player())


func _on_turn_player_changed(player: GamePlayer) -> void:
	if not _move_to_playing_country:
		return
	
	var country: Country = player.playing_country
	if not country:
		return
	
	var target_province: Province
	for province in _game.game.world.provinces.list():
		if province.owner_country and province.owner_country == country:
			target_province = province
			break
	
	if target_province:
		# Need to wait for the world visuals to load
		if not _game.is_node_ready():
			await _game.ready
		
		_camera.move_to(
				_game.world_visuals.province_visuals
				.visuals_of(target_province).global_position_army_host()
		)
