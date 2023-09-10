extends ConfirmationDialog



@onready var delete_btn:Button = get_ok_button()



func _ready():
	delete_btn.focus_mode = Control.FOCUS_NONE
	
