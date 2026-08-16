@abstract
class_name ProvinceActionButton
extends Button
## Base class for buttons that automatically disable themselves when
## given player is unable to perform some action in given province.
## (Or when data is missing.)

## May be null.
var game: Game = null:
	set(value):
		if game == value:
			return
		game = value
		_on_data_changed()

## May be null.
var province: Province = null:
	set(value):
		if province == value:
			return
		province = value
		_on_data_changed()

## May be null.
var player: GamePlayer = null:
	set(value):
		if player == value:
			return

		if player != null:
			player.playing_country_changed.disconnect(_on_data_changed)

		player = value
		_on_data_changed()

		if player != null:
			player.playing_country_changed.connect(_on_data_changed)


func _ready() -> void:
	_refresh_disabled()


@abstract func _refresh_conditions() -> void

@abstract func _can_perform_action() -> bool


func _refresh_disabled() -> void:
	disabled = (
			player == null
			or not MultiplayerUtils.has_gameplay_authority(multiplayer, player)
			or not _can_perform_action()
	)


func _on_data_changed() -> void:
	_refresh_conditions()
	if is_node_ready():
		_refresh_disabled()
