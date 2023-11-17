@tool
class_name IconToogleBtn extends Button


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

var last_icon = null


func _init():
	toggle_mode = true


func _ready():
	last_icon = icon
	set_icon()
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	toggled.connect(_on_toggled)


func set_icon():
	if button_pressed:
		if ico_on:
			icon = ico_on
		modulate = Color.WHITE
	else:
		if ico_off:
			icon = ico_off
		modulate = Color.DIM_GRAY


func set_pressed_without_signal(pressed :bool):
	set_pressed_no_signal(pressed)
	set_icon()


func _on_toggled(_btn_pressed):
	set_icon()

	
