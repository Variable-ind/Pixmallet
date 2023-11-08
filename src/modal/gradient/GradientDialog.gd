class_name GradientDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

enum GradientShape {
	LINEAR,
	RADIAL,
}

enum GradientRepeat {
	NONE,
	REPEAT,
	MIRROR,
	TRUNCATE,
}

var gradient_shape := GradientShape.LINEAR
var gradient_repeat := GradientRepeat.NONE

var gradient_tex: Texture2D
var offsets_tex : ImageTexture
var selection_tex: ImageTexture

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)

var project :Project

var dither_matrices: Array[DitherMatrix] = [
	DitherMatrix.new(
		null, "No Dither"
	),
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
var linear_pos := 50.0
var linear_size := 50.0
var linear_angle := 0
var radial_center := Vector2i(50, 50)
var radial_radius := Vector2i.ONE

var gradient_params :Dictionary :
	get: return {
		"gradient_texture": gradient_tex,
		"offset_texture": offsets_tex,
		"selection": selection_tex,
		"position": linear_pos / 100.0 - 0.5,
		"size": linear_size / 100.0,
		"angle": linear_angle,
		"center": radial_center / 100.0,
		"radius": radial_radius,
		"dither_texture": selected_dither_matrix.texture,
		"repeat": gradient_repeat,
		"shape": gradient_shape,
	}

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
@onready var slider_center_x := %SliderCenterX
@onready var slider_center_y := %SliderCenterY
@onready var slider_radius_x := %SliderRadiusX
@onready var slider_radius_y := %SliderRadiusY

@onready var preview := %Preview


class DitherMatrix:
	var texture: Texture2D
	var name: String

	func _init(_texture: Texture2D, _name: String) -> void:
		texture = _texture
		name = _name


func _ready():
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	
	preview.resized.connect(_on_resized)
	
#	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
#	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# perpare OptShape
	for s in GradientShape:
		opt_shape.add_item(s.capitalize(), GradientShape[s])
		if gradient_shape == GradientShape[s]:
			opt_shape.selected = GradientShape[s]
	
	# perpare OptRepeat
	for r in GradientRepeat:
		opt_repeat.add_item(r.capitalize(), GradientRepeat[r])
		if gradient_repeat == GradientRepeat[r]:
			opt_repeat.selected = GradientRepeat[r]
	
	for i in dither_matrices.size():
		var matrix = dither_matrices[i]
		opt_dithering.add_item(matrix.name)
		if matrix == selected_dither_matrix:
			opt_dithering.selected = i
	
	opt_shape.item_selected.connect(_on_shape_selected)
	opt_repeat.item_selected.connect(_on_repeat_selected)
	opt_dithering.item_selected.connect(_on_dithering_selected)
	
	gradient_edit.updated.connect(_on_gradient_updated)
	
	slider_position.set_value_no_signal(linear_pos)
	slider_size.set_value_no_signal(linear_size)
	
	slider_position.value_changed.connect(_on_position_changed)
	slider_size.value_changed.connect(_on_size_changed)
	slider_angle.value_changed.connect(_on_angle_changed)
	slider_center_x.value_changed.connect(_on_center_x_changed)
	slider_center_y.value_changed.connect(_on_center_y_changed)
	slider_radius_x.value_changed.connect(_on_radius_x_changed)
	slider_radius_y.value_changed.connect(_on_radius_y_changed)
	
	get_tree().set_group("gradient_liner", "visible", true)
	get_tree().set_group("gradient_radial", "visible", false)
	
	confirmed.connect(_on_confirmed)
	visibility_changed.connect(_on_visibility_changed)


func launch(proj :Project,
			selection :Selection,
			gradient_colors :PackedColorArray = []):
	preview_image.fill(Color.TRANSPARENT)
	project = proj
	if selection.has_selected():
		selection_tex = ImageTexture.create_from_image(selection.mask)
	cancel_btn.grab_focus.call_deferred()
	gradient_edit.load_gradient_colors(gradient_colors)
	update_preview()
	visible = true


func update_preview():
	for img in project.current_frame.get_images():
		if preview_image.get_width() != img.get_width() or \
		   preview_image.get_height() != img.get_height():
			preview_image.resize(img.get_width(), img.get_height())
		if img.get_format() != preview_image.get_format():
			preview_image.convert(img.get_format())
		preview_image.blit_rect(img,
								Rect2i(Vector2i.ZERO, img.get_size()), 
								Vector2i.ZERO)

	preview.render(preview_image)
	update_gradient()


func update_gradient():
	var gradient :Gradient = gradient_edit.gradient
	var n_of_colors := gradient.offsets.size()
	# Pass the gradient offsets as an array to the shader
	# ...but since Godot 3.x doesn't support uniform arrays, 
	# instead we construct
	# a nx1 grayscale texture with each offset stored in each pixel,
	# and pass it to the shader
	var offsets_image := Image.create(n_of_colors, 1, false, 
									  Image.FORMAT_L8)
	# Construct an image that contains the selected 
	# colors of the gradient without interpolation
	var gradient_image := Image.create(n_of_colors, 1, false,
									   Image.FORMAT_RGBA8)
	for i in n_of_colors:
		var c := gradient.offsets[i]
		offsets_image.set_pixel(i, 0, Color(c, c, c, c))
		gradient_image.set_pixel(i, 0, gradient.colors[i])

	offsets_tex = ImageTexture.create_from_image(offsets_image)

	if selected_dither_matrix.texture:
		gradient_tex = ImageTexture.create_from_image(gradient_image)
	else:
		gradient_tex = gradient_edit.texture

	preview.update_material(gradient_params)


func _on_confirmed():
	var gen := ShaderImageEffect.new()
	gen.generate_image(project.current_cel.get_image(), 
					   preview.material.shader, 
					   gradient_params,
					   project.size)
	applied.emit()


func _on_shape_selected(index :GradientShape):
	gradient_shape = index
	match gradient_shape:
		GradientShape.LINEAR:
			get_tree().set_group("gradient_linear", "visible", true)
			get_tree().set_group("gradient_radial", "visible", false)
		GradientShape.RADIAL:
			get_tree().set_group("gradient_linear", "visible", false)
			get_tree().set_group("gradient_radial", "visible", true)
	update_gradient()
	

func _on_repeat_selected(index :GradientRepeat):
	gradient_repeat = index
	update_gradient()
	

func _on_dithering_selected(index:int):
	selected_dither_matrix = dither_matrices[index]
	preview.switch_shader(index)
	update_gradient()


func _on_position_changed(val):
	linear_pos = val
	update_gradient()


func _on_size_changed(val):
	linear_size = val
	update_gradient()


func _on_angle_changed(val):
	linear_angle = val
	update_gradient()


func _on_center_x_changed(val):
	radial_center.x = val
	update_gradient()


func _on_center_y_changed(val):
	radial_center.y = val
	update_gradient()
	

func _on_radius_x_changed(val):
	radial_radius.x = val
	update_gradient()


func _on_radius_y_changed(val):
	radial_radius.y = val
	update_gradient()


func _on_gradient_updated(_gradient, _cc):
	update_gradient()


func _on_visibility_changed():
	modal_toggled.emit(visible)


func _on_resized():
	preview.render(preview_image)
