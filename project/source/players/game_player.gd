class_name GamePlayer
## Class responsible for a game's player.
## This player can be either a human or an AI.
## The player may either control a [Country] or spectate.

signal playing_country_changed()
signal human_status_changed(this: GamePlayer)
signal username_changed(this: GamePlayer)
signal player_human_changed()
signal ai_changed(old_ai: PlayerAI, new_ai: PlayerAI)

## Unique identifier. Useful for saving/loading, networking, etc.
var id: int = -1

## May be null, in which case the player is spectating.
var playing_country: Country = null:
	set(value):
		if playing_country == value:
			return
		playing_country = value
		playing_country_changed.emit()

## A reference to this human player's [Player] object.
## May be null, in which case this player is not human.
var player_human: Player = null:
	set(value):
		if player_human == value:
			return

		if player_human != null:
			player_human.username_changed.disconnect(username_changed.emit)

		player_human = value

		if player_human != null:
			player_human.username_changed.connect(
					username_changed.emit.bind(self).unbind(1)
			)

		player_human_changed.emit()
		human_status_changed.emit(self)

## This player's username, when not human.
## May be empty, in which case it doesn't have a username.
var ai_username: String = "":
	set(value):
		if ai_username == value:
			return
		ai_username = value
		username_changed.emit(self)

## This player's AI. Should only be used when the player is not human.
var player_ai := PlayerAI.new():
	set(new_ai):
		var old_ai: PlayerAI = player_ai
		if old_ai == new_ai:
			return
		player_ai = new_ai
		ai_changed.emit(old_ai, new_ai)


func is_spectating() -> bool:
	return playing_country == null


func is_human() -> bool:
	return player_human != null


## For human players, returns the assigned [Player]'s username instead.
func username() -> String:
	if player_human != null:
		return player_human.username()
	else:
		return ai_username


## For human players, sets the assigned [Player]'s username instead.
func set_username(value: String) -> void:
	if player_human != null:
		player_human.set_username(value)
	else:
		ai_username = value


## Returns the username or, if it's an empty string, returns "Spectator"
## when spectating, otherwise returns the playing country's name.
func username_or_default() -> String:
	var current_username: String = username()
	if current_username != "":
		return current_username
	elif is_spectating():
		return "Spectator"
	else:
		return playing_country.name_or_default()
