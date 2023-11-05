class_name ImgHSVDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)

var project :Project

var hue_shift := 0.0
var sat_shift := 0.0
var val_shift := 0.0

var material_params :Dictionary :
	get: return {
		"hue_shift": hue_shift,
		"sat_shift": sat_shift,
		"val_shift": val_shift,
	}

var color := Color.BLACK

@export var preview_bgcolor := Color(1, 1, 1, 0.2)

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()

@onready var slider_hue := %SliderHue
@onready var slider_sat := %SliderSat
@onready var slider_val := %SliderVal

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
	
	slider_hue.value_changed.connect(_on_hue_changed)
	slider_sat.value_changed.connect(_on_sat_changed)
	slider_val.value_changed.connect(_on_val_changed)


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
	update_hsv()


func update_hsv():
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


func _on_hue_changed(val:int):
	hue_shift = val / 360.0
	update_hsv()


func _on_sat_changed(val:int):
	sat_shift = val / 100.0
	update_hsv()


func _on_val_changed(val:int):
	val_shift = val / 100.0
	update_hsv()


func _on_visibility_changed():
	modal_toggled.emit(visible)


func _on_resized():
	preview.render(preview_image)
