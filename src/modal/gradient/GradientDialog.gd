class_name GradientDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

enum {
	LINEAR,
	RADIAL,
	LINEAR_DITHERING,
	RADIAL_DITHERING
}
enum Animate {
	POSITION,
	SIZE,
	ANGLE,
	CENTER_X,
	CENTER_Y,
	RADIUS_X,
	RADIUS_Y
}

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)

var project :Project

var dither_matrices: Array[DitherMatrix] = [
	DitherMatrix.new(
		preload("res://assets/dither-matrices/bayer2.png"),
		"Bayer 2x2"
	),
	DitherMatrix.new(
		preload("res://assets/dither-matrices/bayer4.png"),
		"Bayer 4x4"
	),
	DitherMatrix.new(
		preload("res://assets/dither-matrices/bayer8.png"),
		"Bayer 8x8"
	),
	DitherMatrix.new(
		preload("res://assets/dither-matrices/bayer16.png"),
		"Bayer 16x16"
	),
]
var selected_dither_matrix := dither_matrices[0]

@export var preview_bgcolor := Color(1, 1, 1, 0.2)

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()

@onready var gradient_edit := %GradientEdit
@onready var opt_shape := %OptShape
@onready var opt_dithering := %OptDithering
@onready var opt_repeat := %OptRepeat
@onready var slider_position := %SliderPosition
@onready var slider_size := %SliderSize
@onready var slider_angle := %SliderAngle
@onready var slider_center := %SliderCenter
@onready var radius_slider := %SliderRadius

@onready var preview := %Preview


class DitherMatrix:
	var texture: Texture2D
	var name: String

	func _init(_texture: Texture2D, _name: String) -> void:
		texture = _texture
		name = _name


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
	
	for matrix in dither_matrices:
		opt_dithering.add_item(matrix.name)


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
