extends SpinBox
## This SpinBox is only editable when the given CheckBox is checked.


@export var check_box: CheckBox


func _ready() -> void:
	if not check_box:
		return
	
	editable = check_box.button_pressed
	check_box.toggled.connect(_on_check_box_toggled)


func _on_check_box_toggled(button_pressed: bool) -> void:
	editable = button_pressed
