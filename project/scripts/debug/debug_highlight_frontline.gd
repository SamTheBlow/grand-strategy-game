extends Node
## Highlights the playing player's frontline, for debugging purposes.
## Left click at any time to show the regular frontlines,
## or right click to show the war frontlines.


@export var is_enabled: bool = true
@export var game: Game


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		_show_frontlines()
	elif Input.is_action_just_pressed("mouse_right"):
		_show_war_frontlines()


func _show_frontlines() -> void:
	if not is_enabled or not game:
		return
	
	var player: GamePlayer = game.turn.playing_player()
	
	for province in game.world.provinces.list():
		province.highlight_debug(
				Color.BLUE,
				province.is_frontline(player.playing_country)
		)


func _show_war_frontlines() -> void:
	if not is_enabled or not game:
		return
	
	var player: GamePlayer = game.turn.playing_player()
	
	for province in game.world.provinces.list():
		province.highlight_debug(
				Color.DARK_RED,
				province.is_war_frontline(player.playing_country)
		)
