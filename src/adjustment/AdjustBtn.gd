extends Button

class_name AdjustBtn
# THIS CLASS MIGHT USE FOR MULTIPLE AJUSTMENT BUTTONS.


func _ready():
	self_modulate = Color.WEB_GRAY
	
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_normal)
	

func _on_hover():
	self_modulate = Color.WHITE
	
	
func _on_normal():
	if toggle_mode and button_pressed:
		self_modulate = Color.WHITE
	else:
		self_modulate = Color.WEB_GRAY
		
		
