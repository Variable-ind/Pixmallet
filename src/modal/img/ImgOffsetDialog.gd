class_name ImgOffsetDialog extends ConfirmationDialog

signal modal_toggled(state)
signal applied

var preview_image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
var offset_pos := Vector2i.ZERO

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
	
	input_x.min_value = - proj.size.x
	input_x.max_value = proj.size.x * 2
	input_y.min_value = - proj.size.y
	input_y.max_value = proj.size.y * 2
	
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


func change_offset():
	var rect := Rect2i(Vector2i.ZERO, preview_image.get_size())
	var tmp_img := Image.create(rect.size.x,
								rect.size.y, 
								false,
								Image.FORMAT_RGBA8)
	tmp_img.blit_rect(preview_image, rect, offset_pos)
	preview.render(tmp_img, false)


func _on_pos_x_changed(val :int):
	offset_pos.x = val
	change_offset()


func _on_pos_y_changed(val :int):
	offset_pos.y = val
	change_offset()


func _on_confirmed():
#	for cel in project.selected_cels:
#
	applied.emit()


func _on_visibility_changed():
	modal_toggled.emit(visible)


func _on_resized():
	preview.render(preview_image)
