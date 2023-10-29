class_name CropDialog extends ConfirmationDialog

signal modal_toggled(state)

var project :Project

var pivot := Pivot.TOP_LEFT
var pivot_offset :Vector2i :
	get: return Pivot.get_pivot_offset(pivot, crop_rect.size)
var crop_rect := Rect2i()


@export var frame_line_color := Color.DIM_GRAY
@export var crop_line_color := Color.WHITE

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()
@onready var opt_pivot := %OptPivot
@onready var input_width := %Width
@onready var input_height := %Height

@onready var preview := %Preview


func _ready():
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	
	input_width.max_value = 12000
	input_height.max_value = 12000
	input_width.min_value = 1
	input_height.min_value = 1
	
	input_width.focus_mode = Control.FOCUS_ALL
	input_height.focus_mode = Control.FOCUS_ALL
	
	preview.crop_line_color = crop_line_color
	preview.frame_line_color = frame_line_color
	
#	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
#	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	confirmed.connect(_on_confirmed)
	visibility_changed.connect(_on_visibility_changed)
	
	input_width.value_changed.connect(_on_width_changed)
	input_height.value_changed.connect(_on_height_changed)
	opt_pivot.pivot_updated.connect(_on_pivot_updated)


func load_project(proj:Project):
	project = proj
	crop_rect.size = project.size
	input_width.value = project.size.x
	input_height.value = project.size.y
	cancel_btn.grab_focus.call_deferred()
	update_preview()
	visible = true


func update_preview():
	var preview_image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	for img in project.current_frame.get_images():
		if preview_image.get_width() != img.get_width() or \
		   preview_image.get_height() != img.get_height():
			preview_image.resize(img.get_width(), img.get_height())
		if img.get_format() != preview_image.get_format():
			preview_image.convert(img.get_format())
		preview_image.blit_rect(img,
								Rect2i(Vector2i.ZERO, img.get_size()), 
								Vector2i.ZERO)
	preview.update_texture(preview_image)
	preview.update_rect(crop_rect, project.size)


func resize_to(to_size:Vector2i):
	if to_size.x < 1:
		to_size.x = 1
	if to_size.y < 1:
		to_size.y = 1
		
	var _offset = Pivot.get_pivot_offset(pivot, to_size)
	var coef := Vector2(_offset) / Vector2(to_size)
	var size_diff :Vector2i = Vector2(crop_rect.size - to_size) * coef
	var dest_pos :Vector2i = crop_rect.position + size_diff
	
	crop_rect.position = dest_pos
	crop_rect.size = to_size
	preview.update_rect(crop_rect, project.size)


func _on_confirmed():
	project.crop_to(crop_rect)


func _on_pivot_updated(new_pivot):
	pivot = new_pivot
	var to_size = crop_rect.size
	crop_rect.position = Vector2i.ZERO
	crop_rect.size = project.size
	resize_to(to_size)


func _on_width_changed(value):
	var to_size = crop_rect.size
	to_size.x = value
	resize_to(to_size)


func _on_height_changed(value):
	var to_size = crop_rect.size
	to_size.y = value
	resize_to(to_size)


func _on_visibility_changed():
	modal_toggled.emit(visible)
