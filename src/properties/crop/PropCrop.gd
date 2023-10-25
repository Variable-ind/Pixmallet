class_name PropCrop extends VBoxContainer

var operator :Variant

@onready var btn_apply := %Apply
@onready var btn_cancel := %Cancel
@onready var opt_pivot := %OptPivot
@onready var input_x := %PosX
@onready var input_y := %PosY
@onready var input_width := %Width
@onready var input_height := %Height


func subscribe(new_operator:CropSizer):
	unsubscribe()
	operator = new_operator
	
	input_width.max_value = 12000
	input_height.max_value = 12000
	input_x.max_value = 12000
	input_y.max_value = 12000

	btn_apply.pressed.connect(_on_applied)
	btn_cancel.pressed.connect(_on_canceled)
	input_x.value_changed.connect(_on_position_changed)
	input_y.value_changed.connect(_on_position_changed)
	input_width.value_changed.connect(_on_size_changed)
	input_height.value_changed.connect(_on_size_changed)
	opt_pivot.pivot_updated.connect(_on_pivot_changed)
	operator.updated.connect(_on_transform_updated)
	
	set_editable(false)


func unsubscribe():
	if btn_apply.pressed.is_connected(_on_applied):
		btn_apply.pressed.disconnect(_on_applied)
	if btn_cancel.pressed.is_connected(_on_canceled):
		btn_cancel.pressed.disconnect(_on_canceled)
	if input_x.value_changed.is_connected(_on_position_changed):
		input_x.value_changed.disconnect(_on_position_changed)
	if input_y.value_changed.is_connected(_on_position_changed):
		input_y.value_changed.disconnect(_on_position_changed)
	if input_width.value_changed.is_connected(_on_size_changed):
		input_width.value_changed.disconnect(_on_size_changed)
	if input_height.value_changed.is_connected(_on_size_changed):
		input_height.value_changed.disconnect(_on_size_changed)
	if opt_pivot.pivot_updated.is_connected(_on_pivot_changed):
		opt_pivot.pivot_updated.disconnect(_on_pivot_changed)
	if operator and operator.updated.is_connected(_on_transform_updated):
		operator.updated.disconnect(_on_transform_updated)
	
	set_transform(Rect2i(), false)
	operator = null
	

func set_transform(rect :Rect2i, status := false):
	input_x.set_value_no_signal(rect.position.x)
	input_y.set_value_no_signal(rect.position.y)
	input_width.set_value_no_signal(rect.size.x)
	input_height.set_value_no_signal(rect.size.y)
	set_editable(status)


func set_editable(status):
	input_x.editable = status
	input_y.editable = status
	input_width.editable = status
	input_height.editable = status
	opt_pivot.set_process_input(status)


func _on_applied():
	operator.apply()


func _on_canceled():
	operator.cancel()


func _on_position_changed(_val):
	operator.move_to(Vector2i(input_x.value, input_y.value))
	

func _on_size_changed(_val):
	var width = max(input_width.value, 1)
	var height = max(input_height.value, 1)
	operator.resize_to(Vector2i(width, height))


func _on_pivot_changed(val):
	operator.set_pivot(val)
		

func _on_transform_updated(rect :Rect2i, rel_pos :Vector2i, status := true):
	rect.position = rel_pos
	set_transform(rect, status)
