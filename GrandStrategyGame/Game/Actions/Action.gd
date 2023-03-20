class_name Action
extends Node


signal action_played


# The subclass is expected to call this when it is done
func play_action():
	emit_signal("action_played", self)
	queue_free()
