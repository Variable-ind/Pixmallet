class_name CropDialog extends ConfirmationDialog

signal modal_toggled(state)

var project :Project

var pivot := Pivot.TOP_LEFT
var pivot_offset :Vector2i :
	get: return cal_pivot_offset(pivot, crop_size)
var crop_size := Vector2i.ZERO
var crop_rect : Rect2i :
	get: return Rect2i(pivot_offset, crop_size)


@export var line_color := Color.WHITE

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
	
	preview.line_color = line_color
	
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
	crop_size = project.size
	input_width.value = crop_size.x
	input_height.value = crop_size.y
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
	preview.update_image(preview_image)


func update_preview_rect():
	preview.update_rect(crop_rect)


func cal_pivot_offset(to_pivot, to_size) -> Vector2i:
	var _offset = Vector2i.ZERO
	if to_size == Vector2i.ZERO:
		return _offset
	match to_pivot:
		PivotSelector.PivotPoint.TOP_LEFT:
			pass
			
		PivotSelector.PivotPoint.TOP_CENTER:
			_offset.x = to_size.x / 2.0

		PivotSelector.PivotPoint.TOP_RIGHT:
			_offset.x = to_size.x

		PivotSelector.PivotPoint.MIDDLE_RIGHT:
			_offset.x = to_size.x
			_offset.y = to_size.y / 2.0

		PivotSelector.PivotPoint.BOTTOM_RIGHT:
			_offset.x = to_size.x
			_offset.y = to_size.y

		PivotSelector.PivotPoint.BOTTOM_CENTER:
			_offset.x = to_size.x / 2.0
			_offset.y = to_size.y

		PivotSelector.PivotPoint.BOTTOM_LEFT:
			_offset.y = to_size.y

		PivotSelector.PivotPoint.MIDDLE_LEFT:
			_offset.y = to_size.y / 2.0
		
		PivotSelector.PivotPoint.CENTER:
			_offset.x = to_size.x / 2.0
			_offset.y = to_size.y / 2.0
			
	return _offset


func _on_confirmed():
	project.crop_to(crop_rect)


func _on_pivot_updated(new_pivot):
	pivot = new_pivot
	update_preview_rect()


func _on_width_changed(value):
	crop_size.x = value
	update_preview_rect()


func _on_height_changed(value):
	crop_size.y = value
	update_preview_rect()


func _on_visibility_changed():
	modal_toggled.emit(visible)
