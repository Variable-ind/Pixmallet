class_name CropDialog extends ConfirmationDialog


signal modal_toggled(state)

var project :Project

@onready var confirm_btn:Button = get_ok_button()
@onready var cancel_btn:Button = get_cancel_button()
@onready var opt_pivot := %OptPivot
@onready var input_width := %Width
@onready var input_height := %Height


func _ready():
	input_width.max_value = 12000
	input_height.max_value = 12000
	input_width.min_value = 1
	input_height.min_value = 1
	
	input_width.focus_mode = Control.FOCUS_ALL
	input_height.focus_mode = Control.FOCUS_ALL
	
#	confirm_btn.focus_mode = Control.FOCUS_NONE
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
#	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	confirmed.connect(_on_confirmed)
	visibility_changed.connect(_on_visibility_changed)


func load_project(proj:Project):
	project = proj
	input_width.value = project.size.x
	input_height.value = project.size.y
	cancel_btn.grab_focus.call_deferred()
	visible = true


func _on_confirmed():
	var to_size = Vector2i(input_width.value, input_height.value)
	var pivot_offset = cal_pivot_offset(opt_pivot.pivot_value, to_size)

	project.crop_to(Rect2i(pivot_offset, to_size))


func _on_visibility_changed():
	modal_toggled.emit(visible)


func cal_pivot_offset(pivot, to_size:Vector2i) -> Vector2i:
	var _offset = Vector2i.ZERO
	match pivot:
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
