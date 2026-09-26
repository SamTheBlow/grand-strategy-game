class_name NetworkSyncData
extends Resource
## Data to be synchronized between host and clients.
## Serves as a bridge between the node responsible for the sync
## and the nodes responsible for using the data.

signal selected_project_changed()

## May be null.
var selected_project: MetadataBundle = null:
	set(value):
		if selected_project == value:
			return
		selected_project = value
		selected_project_changed.emit()
