class_name SyncCheck
## Class responsible for checking if everything is synchronized.
## Emits a signal once everything is synchronized.
## You can also check manually if the sync is finished
## with [method SyncCheck.is_sync_finished].
##
## To use, create a new instance of this object and pass it an array
## of all the things you want to check for. The given objects must all
## have a signal named "sync_finished" with one parameter: the object itself.


signal sync_finished()

var _number_of_things_to_check: int = 0


func _init(things_to_check: Array[Object]) -> void:
	for object in things_to_check:
		if object.has_signal("sync_finished"):
			_number_of_things_to_check += 1
			object.connect("sync_finished", _on_sync_finished)
		else:
			push_warning("Provided an object that doesn't have sync_finished!")


func is_sync_finished() -> bool:
	return _number_of_things_to_check == 0


func _on_sync_finished(object: Object) -> void:
	object.disconnect("sync_finished", _on_sync_finished)
	_number_of_things_to_check -= 1
	if _number_of_things_to_check == 0:
		sync_finished.emit()
