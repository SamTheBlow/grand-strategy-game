class_name TroopUI
extends Control


signal cancelled
signal army_moved

const _SCENE := (
		preload("res://Scenes/NumberOfTroops.tscn") as PackedScene
)

var _army: Army
var _source: Province
var _destination: Province


func _on_Cancel_pressed() -> void:
	emit_signal("cancelled")
	queue_free()


func _on_Confirm_pressed() -> void:
	var troop_count := int(_troop_slider().value)
	if troop_count != 0:
		emit_signal("army_moved", _army, troop_count, _source, _destination)
	queue_free()


func _on_troop_slider_value_changed(_value: float) -> void:
	_new_slider_value()


static func new_popup(
		army: Army,
		source: Province,
		destination: Province
) -> TroopUI:
	var popup := _SCENE.instantiate() as TroopUI
	
	popup._army = army
	popup._source = source
	popup._destination = destination
	var slider: Slider = popup._troop_slider()
	slider.max_value = popup._army.troop_count
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
