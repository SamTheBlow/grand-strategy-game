extends Node2D
class_name Army

var owner_country:Country = null setget set_owner_country
var troop_count:int = 1 setget set_troop_count

# Lets the game know this army can still perform actions
var is_active = true setget set_active

func _init(owner_country_:Country = null, troop_count_:int = 1):
	owner_country = owner_country_
	troop_count = troop_count_

func set_owner_country(owner_country_:Country):
	owner_country = owner_country_
	$ColorRect.color = owner_country.color

func set_troop_count(troop_count_:int):
	troop_count = troop_count_
	$ColorRect/MarginContainer/TroopCount.text = String(troop_count)

func set_active(active):
	if active:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		is_active = active
	else:
		is_active = active

func play_movement_to(destination:Vector2):
	is_active = false
	$Movement.move_army(position, destination)

func gray_out():
	var v = 0.5
	modulate = Color(v, v, v, 1.0)

func stop_animations():
	$Movement.stop(true)

func attack(opponent:Army):
	var delta = troop_count - opponent.troop_count
	if delta > 0:
		set_troop_count(delta)
		opponent.queue_free()
	elif delta < 0:
		opponent.set_troop_count(-delta)
		queue_free()
	else:
		opponent.queue_free()
		queue_free()

# Temporary......
func location():
	return get_parent().get_parent()
