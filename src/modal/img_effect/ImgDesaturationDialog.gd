class_name ImgDesaturationDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)

var project :Project

var red := true
var blue := true
var green := true
var alpha := false

var material_params :Dictionary :
	get: return {
		"red": red, 
		"blue": blue, 
		"green": green, 
		"alpha": alpha,
	}

var color := Color.BLACK

@export var preview_bgcolor := Color(1, 1, 1, 0.2)

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()

@onready var invert_red := %InvertRed
@onready var invert_blue := %InvertBlue
@onready var invert_green := %InvertGreen
@onready var invert_alpha := %InvertAlpha

@onready var preview := %Preview


func _ready():
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	
	preview.bgcolor = preview_bgcolor
	preview.resized.connect(_on_resized)
	
#	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
#	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	confirmed.connect(_on_confirmed)
	visibility_changed.connect(_on_visibility_changed)
	
	invert_red.button_pressed = red
	invert_blue.button_pressed = blue
	invert_green.button_pressed = green
	invert_alpha.button_pressed = alpha
	
	invert_red.toggled.connect(_on_red_toggled)
	invert_blue.toggled.connect(_on_blue_toggled)
	invert_green.toggled.connect(_on_green_toggled)
	invert_alpha.toggled.connect(_on_alpha_toggled)


func launch(proj:Project):
	preview_image.fill(Color.TRANSPARENT)
	project = proj
	cancel_btn.grab_focus.call_deferred()
	update_preview()
	visible = true


func update_preview():
	for cel in project.selected_cels:
		var img = cel.get_image()
		if preview_image.get_width() != img.get_width() or \
		   preview_image.get_height() != img.get_height():
			preview_image.resize(img.get_width(), img.get_height())
		if img.get_format() != preview_image.get_format():
			preview_image.convert(img.get_format())
		preview_image.blit_rect(img,
								Rect2i(Vector2i.ZERO, img.get_size()), 
								Vector2i.ZERO)

	preview.render(preview_image)
	confirm_btn.disabled = preview_image.is_invisible()
	update_desaturation()


func update_desaturation():
	preview.update_material(material_params)


func _on_confirmed():
	var gen := ShaderImageEffect.new()
	for cel in project.selected_cels:
		gen.generate_image(cel.get_image(), 
						   preview.material.shader, 
						   material_params,
						   project.size)
#		await gen.done  # DONT NEED it. otherwise will borken the loop.
	applied.emit()


func _on_red_toggled(btn_pressed:bool):
	red = btn_pressed
	update_desaturation()


func _on_blue_toggled(btn_pressed:bool):
	blue = btn_pressed
	update_desaturation()


func _on_green_toggled(btn_pressed:bool):
	green = btn_pressed
	update_desaturation()


func _on_alpha_toggled(btn_pressed:bool):
	alpha = btn_pressed
	update_desaturation()


func _on_visibility_changed():
	modal_toggled.emit(visible)


func _on_resized():
	preview.render(preview_image)
