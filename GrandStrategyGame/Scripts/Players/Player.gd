class_name Player
extends Node


var id: int

var playing_country: Country

var actions: Array[Action] = []


func add_action(action: Action) -> void:
	actions.append(action)


func clear_actions() -> void:
	actions.clear()


static func from_JSON(json_data: Dictionary, countries: Countries) -> Player:
	var player := TestAI1.new()
	player.id = json_data["id"]
	player.playing_country = (
			countries.country_from_id(json_data["playing_country_id"])
	)
	player.name = str(player.id)
	return player


func as_JSON() -> Dictionary:
	return {
		"id": id,
		"playing_country_id": playing_country.id,
	}
