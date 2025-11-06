class_name GamePlayer
## Class responsible for a game's player.
## This player can be either a human or an AI.
## The player may either control a [Country] or spectate.

signal playing_country_changed()
signal human_status_changed(this: GamePlayer)
signal username_changed(this: GamePlayer)

## Unique identifier. Useful for saving/loading, networking, etc.
var id: int = -1

## May be null, in which case the player is spectating.
var playing_country: Country = null:
	set(value):
		if playing_country == value:
			return
		playing_country = value
		playing_country_changed.emit()

## Note that if you are turning this player into a human, then
## you might want to set the player_human property before setting this one
var is_human: bool = false:
	set(value):
		is_human = value
		if not is_human:
			player_human = null
		human_status_changed.emit(self)

## This player's username. Allows you to give AI players a username.
## Changing this value automatically changes a human [Player]'s username.
## If this property is set to an empty String, then it returns "Spectator"
## when spectating, otherwise returns the playing country's name.
var username: String = "":
	get:
		if username != "":
			return username
		elif is_spectating():
			return "Spectator"
		else:
			return playing_country.name_or_default()
	set(value):
		if username == value:
			return

		username = value

		if is_human and player_human:
			player_human.set_username(value)

		username_changed.emit(self)

## A reference to this human player's [Player] object.
## It is only relevant when [code]is_human[/code] is set to true.
## This can intentionally be null, even after everything is set up.
var player_human: Player:
	set(value):
		if player_human:
			player_human.username_changed.disconnect(_on_username_changed)

		if value:
			player_human = null
			username = value.username()
			value.username_changed.connect(_on_username_changed)

		player_human = value

## This player's AI.
## It may only be used when [code]is_human[/code] is set to false.
var player_ai := PlayerAI.new()


func is_spectating() -> bool:
	return playing_country == null


func _on_username_changed(new_username: String) -> void:
	username = new_username
