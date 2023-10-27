extends ConfirmationDialog


signal create_confirmed(text)

const UNTITLED_NAME:String = 'Untitled' 

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()
@onready var input_name:LineEdit = $MarginContainer/InputName


func _ready():
	register_text_enter(input_name)
	
	confirm_btn.disabled = true
#	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
#	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	confirmed.connect(_on_confirmed)
	input_name.text_changed.connect(_on_input_name_text_changed)
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed():
	if visible:
		input_name.grab_focus.call_deferred()


func _on_confirmed():
	var output = input_name.text
	input_name.clear()
	if not output:
		output = UNTITLED_NAME
	create_confirmed.emit(output)


func _on_input_name_text_changed(new_text):
	if new_text:
		confirm_btn.disabled = false
	else:
		confirm_btn.disabled = true
