class_name RelationshipPresetLabel
extends Label
## Updates its text and color to match
## the [DiplomacyPreset] of given [DiplomacyRelationship].
## Hides itself if no relationship is given.

var relationship: DiplomacyRelationship:
	set(value):
		if value == relationship:
			return
		if (
				relationship != null
				and
				relationship.preset_changed.is_connected(_on_preset_changed)
		):
				relationship.preset_changed.disconnect(_on_preset_changed)
		relationship = value
		if (
				relationship != null
				and not
				relationship.preset_changed.is_connected(_on_preset_changed)
		):
				relationship.preset_changed.connect(_on_preset_changed)

		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return

	if relationship == null:
		hide()
		return

	_update_label(relationship.preset())
	show()


func _update_label(preset: DiplomacyPreset) -> void:
	add_theme_color_override("font_color", preset.color)
	text = "(" + preset.name + ")"


func _on_preset_changed(_relationship: DiplomacyRelationship) -> void:
	_update_label(relationship.preset())
