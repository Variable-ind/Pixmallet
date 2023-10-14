extends ConfirmationDialog


signal create_dialog_confirmed(text)

const UNTITLED_NAME:String = 'Untitled' 

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()
@onready var inputName:LineEdit = $MarginContainer/inputName


func _ready():
	register_text_enter(inputName)
	
	inputName.grab_focus()
	
	confirm_btn.disabled = true
	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	confirmed.connect(_on_confirmed)
	inputName.text_changed.connect(_on_input_name_text_changed)
	

func _on_confirmed():
	var output = inputName.text
	inputName.clear()
	if not output:
		output = UNTITLED_NAME
	create_dialog_confirmed.emit(output)


func _on_input_name_text_changed(new_text):
	if new_text:
		confirm_btn.disabled = false
	else:
		confirm_btn.disabled = true
