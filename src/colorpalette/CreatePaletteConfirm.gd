extends ConfirmationDialog


signal create_dialog_confirmed(text)

const UNTITLED_NAME:String = 'Untitled' 

@onready var confirm_btn:Button = get_ok_button()
@onready var inputName:LineEdit = $MarginContainer/inputName


func _ready():
	register_text_enter(inputName)
	confirm_btn.disabled = true
	confirm_btn.focus_mode = Control.FOCUS_NONE
	

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
