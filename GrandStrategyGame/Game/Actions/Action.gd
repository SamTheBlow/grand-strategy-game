extends Node
class_name Action

signal action_played

# The subclass is expected to call this when it is done
func play_action():
	emit_signal("action_played", self)
	queue_free()
