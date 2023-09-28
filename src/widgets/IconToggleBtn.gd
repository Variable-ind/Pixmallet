@tool
class_name IconToogleBtn extends Button

signal layer_btn_toggled(toggled_state, is_triggered)


@export var is_pressed = false :
	set(val):
		is_pressed = bool(val)
		button_pressed = is_pressed
		set_icon()

@export var ico_on: Texture2D :
	set(val):
		ico_on = val
		set_icon()

@export var ico_off: Texture2D :
	set(val):
		ico_off = val
		set_icon()


func _init():
	toggle_mode = true

func _ready():
	set_icon()
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	toggled.connect(_on_toggled)


func set_icon():
	if button_pressed:
		icon = ico_on
		modulate = Color.WHITE
	else:
		icon = ico_off
		modulate = Color.DIM_GRAY


func _on_toggled(_btn_pressed):
	set_icon()
