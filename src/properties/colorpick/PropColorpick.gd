class_name PropColorpick extends VBoxContainer

var operator :Variant

@onready var opt_alpha := $OptAlpha
@onready var color_preview := $ColorPreview
@onready var icon_colorpick := $ColorPreview/icon


func subscribe(new_operator:ColorPick):
	unsubscribe()
	operator = new_operator
	opt_alpha.button_pressed = operator.opt_alpha_sensitivity
	
	operator.color_picked.connect(_on_color_picked)
	opt_alpha.toggled.connect(_on_alpha_sensitivity_chenged)


func unsubscribe():
	if operator and operator.color_picked.is_connected(_on_color_picked):
		operator.color_picked.disconnect(_on_color_picked)
	if opt_alpha.toggled.is_connected(_on_alpha_sensitivity_chenged):
		opt_alpha.toggled.disconnect(_on_alpha_sensitivity_chenged)
	operator = null


func _on_color_picked(color:Color):
	color_preview.color = color
	if color.get_luminance() > 0.5:
		icon_colorpick.modulate = Color.BLACK
	else:
		icon_colorpick.modulate = Color.WHITE


func _on_alpha_sensitivity_chenged(btn_pressed):
	operator.opt_alpha_sensitivity = btn_pressed
