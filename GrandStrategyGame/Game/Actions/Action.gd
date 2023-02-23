extends Node
class_name Action

# The subclass is expected to call this when it is done
func play_action():
	queue_free()
