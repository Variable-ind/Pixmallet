extends ConfirmationDialog

@onready var delete_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()
@onready var hint:Label = $MarginContainer/hint


func _ready():
	delete_btn.focus_mode = Control.FOCUS_NONE
	delete_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func set_hint(text:String):
	hint.text = text
	
