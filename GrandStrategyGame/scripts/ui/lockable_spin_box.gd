extends SpinBox
## This SpinBox is only editable when the given CheckBox is checked.


@export var check_box: CheckBox

## If disabled, the SpinBox will only be editable
## when the CheckBox is [b]unchecked[/b], rather than checked.
@export var when_checked: bool = true


func _ready() -> void:
	if not check_box:
		return
	
	_on_check_box_toggled(check_box.button_pressed)
	check_box.toggled.connect(_on_check_box_toggled)


func _on_check_box_toggled(button_pressed: bool) -> void:
	editable = button_pressed
	if not when_checked:
		editable = not editable
