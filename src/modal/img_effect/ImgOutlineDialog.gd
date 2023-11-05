class_name ImgOutlineDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)

var project :Project

var thickness := 1
var inside_image := false
var pattern := 0

var material_params :Dictionary :
	get: return {
		"color": color,
		"width": thickness,
		"pattern": pattern,
		"inside": inside_image
	}

var color := Color.BLACK

@export var frame_line_color := Color.DIM_GRAY

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()

@onready var input_thickness := %Thickness
@onready var color_picker := %ColorPickerButton
@onready var opt_inside_image := %OptInsideImage
@onready var btn_diamond := %BtnDiamond
@onready var btn_square := %BtnSquare
@onready var btn_circle := %BtnCircle


@onready var preview := %Preview


func _ready():
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	
	preview.frame_line_color = frame_line_color
	preview.resized.connect(_on_resized)
	color_picker.get_picker().presets_visible = false
	color_picker.color = color
	btn_diamond.button_pressed = true
	
#	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
#	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	confirmed.connect(_on_confirmed)
	visibility_changed.connect(_on_visibility_changed)
	
	input_thickness.value_changed.connect(_on_thickness_changed)
	opt_inside_image.toggled.connect(_on_inside_image_changed)
	color_picker.color_changed.connect(_on_color_changed)
	btn_diamond.toggled.connect(_on_pattern_selected.bind(0))
	btn_circle.toggled.connect(_on_pattern_selected.bind(1))
	btn_square.toggled.connect(_on_pattern_selected.bind(2))


func launch(proj:Project, new_color:Color):
	preview_image.fill(Color.TRANSPARENT)
	project = proj
	color = new_color
	color_picker.color = new_color
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
	update_outline()


func update_outline():
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


func _on_pattern_selected(_pressed, index:int):
	pattern = index
	update_outline()


func _on_thickness_changed(value:int):
	thickness = value
	update_outline()


func _on_inside_image_changed(btn_pressed:bool):
	inside_image = btn_pressed
	update_outline()


func _on_color_changed(new_color:Color):
	color = new_color
	update_outline()
	

func _on_visibility_changed():
	modal_toggled.emit(visible)


func _on_resized():
	preview.render(preview_image)
