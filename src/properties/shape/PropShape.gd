class_name PropShape extends VBoxContainer

var operator :Variant

@onready var btn_apply := %Apply
@onready var btn_cancel := %Cancel
@onready var stroke_width := %StrokeWidth
@onready var opt_fill := %OptFill
@onready var opt_as_square := %OptAsSquare
@onready var opt_from_center := %OptFromCenter
@onready var opt_pivot := %OptPivot
@onready var polygon_division := %PolygonDivision
@onready var polygon_expansion := %PolygonExpansion
@onready var input_x := %PosX
@onready var input_y := %PosY
@onready var input_width := %Width
@onready var input_height := %Height


func _ready():
	input_width.max_value = 12000
	input_height.max_value = 12000
	input_x.max_value = 12000
	input_y.max_value = 12000


func subscribe(new_operator:Silhouette):
	unsubscribe()
	operator = new_operator
	
	
	stroke_width.min_value = operator.STROKE_WIDTH_MIN
	stroke_width.max_value = operator.STROKE_WIDTH_MAX
	stroke_width.value = operator.stroke_width  # max/min defined in operator.
	
	opt_fill.button_pressed = operator.opt_fill
	opt_as_square.button_pressed = operator.opt_as_square
	opt_from_center.button_pressed = operator.opt_from_center
	
	polygon_division.value = operator.division
	polygon_expansion.value = operator.edge_expansion
	
	btn_apply.pressed.connect(_on_applied)
	btn_cancel.pressed.connect(_on_canceled)
	
	stroke_width.value_changed.connect(_on_stroke_width_changed)
	opt_fill.toggled.connect(_on_fill_toggled)
	opt_as_square.toggled.connect(_on_as_square_toggled)
	opt_from_center.toggled.connect(_on_from_center_toggled)
	
	input_x.value_changed.connect(_on_position_changed)
	input_y.value_changed.connect(_on_position_changed)
	input_width.value_changed.connect(_on_size_changed)
	input_height.value_changed.connect(_on_size_changed)
	opt_pivot.pivot_updated.connect(_on_pivot_changed)
	polygon_division.value_changed.connect(_on_division_changed)
	polygon_expansion.value_changed.connect(_on_expansion_changed)
	operator.updated.connect(_on_transform_updated)
	
	set_editable(false)


func unsubscribe():
	if btn_apply.pressed.is_connected(_on_applied):
		btn_apply.pressed.disconnect(_on_applied)
	if btn_cancel.pressed.is_connected(_on_canceled):
		btn_cancel.pressed.disconnect(_on_canceled)
		
	if stroke_width.value_changed.is_connected(_on_stroke_width_changed):
		stroke_width.value_changed.disconnect(_on_stroke_width_changed)
	if opt_fill.toggled.is_connected(_on_fill_toggled):
		opt_fill.toggled.disconnect(_on_fill_toggled)
	if opt_as_square.toggled.is_connected(_on_as_square_toggled):
		opt_as_square.toggled.disconnect(_on_as_square_toggled)
	if opt_from_center.toggled.is_connected(_on_from_center_toggled):
		opt_from_center.toggled.disconnect(_on_from_center_toggled)
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
	if polygon_division.value_changed.is_connected(_on_division_changed):
		polygon_division.value_changed.disconnect(_on_division_changed)
	if polygon_expansion.value_changed.is_connected(_on_expansion_changed):
		polygon_expansion.value_changed.disconnect(_on_expansion_changed)
	if operator and operator.updated.is_connected(_on_transform_updated):
		operator.updated.disconnect(_on_transform_updated)
	
	set_transform(Rect2i(), false)
	operator = null


func set_for_polygon(use_polygon := false):
	polygon_division.visible = use_polygon
	polygon_expansion.visible = use_polygon


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


func _on_stroke_width_changed(value):
	operator.stroke_width = value
	

func _on_fill_toggled(btn_pressed):
	operator.opt_fill = btn_pressed


func _on_as_square_toggled(btn_pressed):
	operator.opt_as_square = btn_pressed
	
	
func _on_from_center_toggled(btn_pressed):
	operator.opt_from_center = btn_pressed


func _on_division_changed(value):
	operator.division = value


func _on_expansion_changed(value):
	operator.edge_expansion = value
	

func _on_applied():
	operator.apply()


func _on_canceled():
	operator.cancel()
