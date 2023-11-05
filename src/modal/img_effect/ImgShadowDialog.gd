class_name ImgShadowDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)

var project :Project

var offset_size := Vector2i.ONE

var material_params :Dictionary :
	get: return {
		"shadow_offset": Vector2(offset_size.x, offset_size.y),
		"shadow_color": color,
	}

var color := Color.BLACK

@export var preview_bgcolor := Color(1, 1, 1, 0.2)

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()

@onready var color_picker := %ColorPickerButton
@onready var input_offset_x := %OffsetX
@onready var input_offset_y := %OffsetY

@onready var preview := %Preview


func _ready():
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	
	preview.bgcolor = preview_bgcolor
	preview.resized.connect(_on_resized)
	color_picker.get_picker().presets_visible = false
	color_picker.color = color
	
#	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
#	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	confirmed.connect(_on_confirmed)
	visibility_changed.connect(_on_visibility_changed)
	
	input_offset_x.value_changed.connect(_on_offset_x_changed)
	input_offset_y.value_changed.connect(_on_offset_y_changed)
	color_picker.color_changed.connect(_on_color_changed)


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
	update_dropshadow()


func update_dropshadow():
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


func _on_offset_x_changed(value:int):
	offset_size.x = value
	update_dropshadow()


func _on_offset_y_changed(value:int):
	offset_size.y = value
	update_dropshadow()


func _on_color_changed(new_color:Color):
	color = new_color
	update_dropshadow()
	

func _on_visibility_changed():
	modal_toggled.emit(visible)


func _on_resized():
	preview.render(preview_image)
