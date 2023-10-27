class_name PropSelection extends VBoxContainer

var operator :Variant

@onready var mode_new := %ModeNew
@onready var mode_add := %ModeAdd
@onready var mode_subtract := %ModeSubtract
@onready var mode_intersect := %ModeIntersect

@onready var opt_as_square := %OptAsSquare
@onready var opt_from_center := %OptFromCenter
@onready var opt_pivot := %OptPivot

@onready var similarity := %Similarity
@onready var opt_contiguous := %OptContiguous
@onready var options := %Options

@onready var input_x := %PosX
@onready var input_y := %PosY
@onready var input_width := %Width
@onready var input_height := %Height


func _ready():
	input_width.max_value = 12000
	input_height.max_value = 12000
	input_x.max_value = 12000
	input_y.max_value = 12000


func subscribe(new_operator:Selection):
	unsubscribe()
	operator = new_operator
	
	similarity.value = operator.similarity  # max/min defined in operator.
	
	mode_new.toggled.connect(_on_mode_toggled.bind(Selection.Mode.REPLACE))
	mode_add.toggled.connect(_on_mode_toggled.bind(Selection.Mode.ADD))
	mode_subtract.toggled.connect(_on_mode_toggled.bind(Selection.Mode.SUBTRACT))
	mode_intersect.toggled.connect(_on_mode_toggled.bind(Selection.Mode.INTERSECTION))
	
	mode_new.button_pressed = operator.as_replace
	mode_add.button_pressed = operator.as_add
	mode_subtract.button_pressed = operator.as_subtract
	mode_intersect.button_pressed = operator.as_intersect
	
	opt_as_square.button_pressed = operator.opt_as_square
	opt_from_center.button_pressed = operator.opt_from_center

	opt_as_square.toggled.connect(_on_as_square_toggled)
	opt_from_center.toggled.connect(_on_from_center_toggled)
	
	similarity.value_changed.connect(_on_similarity_changed)
	opt_contiguous.toggled.connect(_on_contiguous_toggled)
	
	input_x.value_changed.connect(_on_position_changed)
	input_y.value_changed.connect(_on_position_changed)
	input_width.value_changed.connect(_on_size_changed)
	input_height.value_changed.connect(_on_size_changed)
	
	opt_pivot.pivot_updated.connect(_on_pivot_changed)
	
	operator.updated.connect(_on_selection_updated)
	
	set_editable(false)


func unsubscribe():
	if mode_new.toggled.is_connected(_on_mode_toggled):
		mode_new.toggled.disconnect(_on_mode_toggled)
	if mode_add.toggled.is_connected(_on_mode_toggled):
		mode_add.toggled.disconnect(_on_mode_toggled)
	if mode_subtract.toggled.is_connected(_on_mode_toggled):
		mode_subtract.toggled.disconnect(_on_mode_toggled)
	if mode_intersect.toggled.is_connected(_on_mode_toggled):
		mode_intersect.toggled.disconnect(_on_mode_toggled)
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
		
	if similarity.value_changed.is_connected(_on_similarity_changed):
		similarity.value_changed.disconnect(_on_similarity_changed)
	if opt_contiguous.toggled.is_connected(_on_contiguous_toggled):
		opt_contiguous.toggled.disconnect(_on_contiguous_toggled)

	if operator and operator.updated.is_connected(_on_selection_updated):
		operator.updated.disconnect(_on_selection_updated)
	
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


func set_for_magic_selector(status):
	similarity.visible = status
	opt_contiguous.visible = status
	options.visible = not status


func _on_position_changed(_val):
	operator.move_to(Vector2i(input_x.value, input_y.value))
	

func _on_size_changed(_val):
	var width = max(input_width.value, 1)
	var height = max(input_height.value, 1)
	operator.resize_to(Vector2i(width, height))


func _on_pivot_changed(val):
	operator.set_pivot(val)
		

func _on_selection_updated(rect :Rect2i, rel_pos :Vector2i):
	if rect.has_area():
		rect.position = rel_pos
	else:
		rect.position = Vector2i.ZERO
	set_transform(rect, rect.has_area())


func _on_as_square_toggled(btn_pressed):
	operator.opt_as_square = btn_pressed
	
	
func _on_from_center_toggled(btn_pressed):
	operator.opt_from_center = btn_pressed


func _on_mode_toggled(btn_pressed, mode):
	if btn_pressed:
		operator.mode = mode


func _on_similarity_changed(value):
	operator.similarity = value


func _on_contiguous_toggled(btn_pressed):
	operator.opt_contiguous = btn_pressed
