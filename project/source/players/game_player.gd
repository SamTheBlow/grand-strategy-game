class_name GamePlayer
## Class responsible for a game's player.
## This player can be either a human or an AI.
## The player may either control a [Country] or spectate.


signal human_status_changed(this: GamePlayer)
signal username_changed(this: GamePlayer)

## The unique id assigned to this player.
## Each player has its own id. Useful for saving/loading, networking, etc.
var id: int = -1

## Null means the player is spectating.
var playing_country: Country

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
			return playing_country.country_name
	set(value):
		if username == value:
			return

		username = value

		if is_human and player_human:
			player_human.custom_username = value

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

# TODO this is ugly
## For loading purposes. -1 means it doesn't represent any human player.
var player_human_id: int = -1:
	get:
		if player_human:
			return player_human.id
		return player_human_id

## This player's AI.
## It may only be used when [code]is_human[/code] is set to false.
var player_ai := PlayerAI.new()


func is_spectating() -> bool:
	return playing_country == null


## For saving/loading purposes
func raw_data() -> Dictionary:
	var player_data: Dictionary = {}
	player_data["id"] = id
	if playing_country:
		player_data["playing_country_id"] = playing_country.id
	player_data["is_human"] = is_human
	player_data["username"] = username
	if is_human and player_human:
		player_data["human_id"] = player_human.id
	player_data["ai_type"] = player_ai.type()
	player_data["ai_personality_type"] = player_ai.personality.type()
	return player_data


func _on_username_changed(new_username: String) -> void:
	username = new_username
