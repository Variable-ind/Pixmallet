class_name ImgOffsetDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
var offset_pos := Vector2i.ZERO:
	set(val):
		offset_pos = val.clamp(min_offset_pos, max_offset_pos)

var min_offset_pos := Vector2i.ZERO
var max_offset_pos := Vector2i.ZERO

var project :Project

@export var frame_line_color := Color.DIM_GRAY

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()
@onready var preview := %Preview

@onready var input_x := %PosX
@onready var input_y := %PosY


func _ready():
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	
	preview.frame_line_color = frame_line_color
	preview.resized.connect(_on_resized)
	
#	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
#	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	confirmed.connect(_on_confirmed)
	visibility_changed.connect(_on_visibility_changed)
	
	input_x.value_changed.connect(_on_pos_x_changed)
	input_y.value_changed.connect(_on_pos_y_changed)


func launch(proj:Project):
	preview_image.fill(Color.TRANSPARENT)
	offset_pos = Vector2i.ZERO
	project = proj
	
	min_offset_pos = Vector2i(- proj.size.x, - proj.size.y)
	max_offset_pos = Vector2i(proj.size.x, proj.size.y)
	
	input_x.min_value = min_offset_pos.x
	input_x.max_value = max_offset_pos.x
	input_y.min_value = min_offset_pos.y
	input_y.max_value = max_offset_pos.y
	
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


#func change_preview_offset():
	# DO NEED those, save more performance.
#	var rect := Rect2i(Vector2i.ZERO, preview_image.get_size())
#	var repeat_img := Image.create(rect.size.x * 4,
#								   rect.size.y * 4, 
#								   false,
#								   Image.FORMAT_RGBA8)
#	repeat_img.blit_rect(preview_image, rect, Vector2i.ZERO)
#	repeat_img.blit_rect(preview_image, rect, Vector2i(0, rect.size.y))
#	repeat_img.blit_rect(preview_image, rect, Vector2i(rect.size.x, 0))
#	repeat_img.blit_rect(preview_image, rect, rect.size)
#
#	var tmp_img := Image.create(rect.size.x,
#								rect.size.y, 
#								false,
#								Image.FORMAT_RGBA8)
#	var tmp_rect := Rect2i(offset_pos, rect.size)
#	if tmp_rect.position.x < 0:
#		tmp_rect.position.x += rect.size.x
#	if tmp_rect.position.y < 0:
#		tmp_rect.position.y += rect.size.y
#	tmp_img.blit_rect(repeat_img, tmp_rect, Vector2i.ZERO)
#	preview.render(tmp_img, false)


func change_preview_offset():
	var tmp_img := preview_image.duplicate()
	offset_image(tmp_img)
	preview.render(tmp_img, false)


func offset_image(img :Image):
	var rect := Rect2i(Vector2i.ZERO, img.get_size())
	var repeat_img := Image.create(rect.size.x * 4,
								   rect.size.y * 4, 
								   false,
								   Image.FORMAT_RGBA8)
	repeat_img = img.duplicate()
	var tmp_pos := Vector2i(offset_pos)
	
	if tmp_pos.x < 0:
		tmp_pos.x += rect.size.x
	if tmp_pos.y < 0:
		tmp_pos.y += rect.size.y

	img.fill(Color.TRANSPARENT)
	img.blit_rect(repeat_img, rect, tmp_pos)
	img.blit_rect_mask(repeat_img, repeat_img, rect, 
					   Vector2i(tmp_pos.x, tmp_pos.y - rect.size.y))
	img.blit_rect_mask(repeat_img, repeat_img, rect, 
					   Vector2i(tmp_pos.x - rect.size.x, tmp_pos.y))
	img.blit_rect_mask(repeat_img, repeat_img, rect, tmp_pos - rect.size)


func _on_pos_x_changed(val :int):
	offset_pos.x = val
	change_preview_offset()


func _on_pos_y_changed(val :int):
	offset_pos.y = val
	change_preview_offset()


func _on_confirmed():
	if offset_pos != Vector2i.ZERO:
		for cel in project.selected_cels:
			offset_image(cel.get_image())
	applied.emit()


func _on_visibility_changed():
	modal_toggled.emit(visible)


func _on_resized():
	preview.render(preview_image)
