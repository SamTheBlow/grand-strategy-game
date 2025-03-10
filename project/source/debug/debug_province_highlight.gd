class_name DebugProvinceHighlight
extends Node
## Highlights some specific set of provinces, for debugging purposes.
## Left click or right click to toggle between two different sets.

@export var is_enabled: bool = true
@export var _game: GameNode


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		_highlight_provinces(Color.BLUE, _province_filter_frontline)
	elif Input.is_action_just_pressed("mouse_right"):
		#_highlight_provinces(Color.DARK_RED, _province_filter_war_frontline)
		_highlight_provinces(Color.GREEN, _province_filter_testai1)


func _province_filter_frontline(province: Province) -> bool:
	return province.is_frontline(
			_game.game.turn.playing_player().playing_country
	)


func _province_filter_war_frontline(province: Province) -> bool:
	return province.is_war_frontline(
			_game.game.turn.playing_player().playing_country
	)


func _province_filter_testai1(province: Province) -> bool:
	return (
			province.owner_country == null
			or not _game.game.turn.playing_player().playing_country
			.has_permission_to_move_into_country(province.owner_country)
	)


func _highlight_provinces(color: Color, province_filter: Callable) -> void:
	if not is_enabled or _game.world_visuals.province_visuals == null:
		return

	for province_visuals in _game.world_visuals.province_visuals.list:
		province_visuals.highlight_debug(
				color, province_filter.call(province_visuals.province)
		)
