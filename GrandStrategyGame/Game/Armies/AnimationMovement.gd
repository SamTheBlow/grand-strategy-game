extends AnimationPlayer

func move_army(from:Vector2, to:Vector2):
	var animation_name = "Movement"
	var movement = get_animation(animation_name)
	var positionTrack = movement.find_track(".:position", Animation.TrackType.TYPE_VALUE)
	var key0 = movement.track_find_key(positionTrack, 0.0)
	var key1 = movement.track_find_key(positionTrack, 1.0)
	movement.track_set_key_value(positionTrack, key0, from)
	movement.track_set_key_value(positionTrack, key1, to)
	play(animation_name)
