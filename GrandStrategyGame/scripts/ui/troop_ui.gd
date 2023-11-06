class_name TroopUI
extends Control


signal cancelled()
signal army_movement_requested(
	army: Army,
	troop_count: int,
	source: Province,
	destination: Province
)


var _army: Army
var _source: Province
var _destination: Province


func _on_cancel_pressed() -> void:
	cancelled.emit()
	queue_free()


func _on_confirm_pressed() -> void:
	var troop_count := int(_troop_slider().value)
	army_movement_requested.emit(_army, troop_count, _source, _destination)
	queue_free()


func _on_troop_slider_value_changed(_value: float) -> void:
	_new_slider_value()


static func new_popup(
		army: Army,
		source: Province,
		destination: Province,
		scene: PackedScene
) -> TroopUI:
	# WARNING (Godot 4.1.2)
	# You can't preload the scene here. If you do,
	# you'll get weird error messages and the scene will become corrupt
	var popup := scene.instantiate() as TroopUI
	
	popup._army = army
	popup._source = source
	popup._destination = destination
	var slider: Slider = popup._troop_slider()
	slider.max_value = popup._army.army_size.current_size()
	slider.value = slider.max_value
	popup._new_slider_value()
	
	return popup


func _troop_slider() -> Slider:
	return %TroopSlider as Slider


func _troop_label() -> Label:
	return %TroopCount as Label


func _new_slider_value() -> void:
	var value := int(_troop_slider().value)
	var max_value := int(_troop_slider().max_value)
	_troop_label().text = str(value) + " | " + str(max_value - value)
