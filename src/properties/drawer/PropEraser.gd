class_name PropEraser extends VBoxContainer

var operator :Variant
	
@onready var eraser_width := $EraserWidth
@onready var opacity := $Opacity
@onready var dynamics_stroke := $DynamicsStroke


func subscribe(new_operator:EraseDrawer):
	unsubscribe()
	operator = new_operator
	eraser_width.min_value = operator.STROKE_WIDTH_MIN
	eraser_width.max_value = operator.STROKE_WIDTH_MAX
	eraser_width.value = operator.stroke_width  # max/min defined in operator.
	opacity.value = floor(operator.alpha * 100)
	
	eraser_width.value_changed.connect(_on_eraser_width_changed)
	opacity.value_changed.connect(_on_opacity_changed)
	dynamics_stroke.item_selected.connect(_on_stroke_dynamics)


func unsubscribe():
	if eraser_width.value_changed.is_connected(_on_eraser_width_changed):
		eraser_width.value_changed.disconnect(_on_eraser_width_changed)
	if opacity.value_changed.is_connected(_on_opacity_changed):
		opacity.value_changed.disconnect(_on_opacity_changed)
	if dynamics_stroke.item_selected.is_connected(_on_stroke_dynamics):
		dynamics_stroke.item_selected.disconnect(_on_stroke_dynamics)

	operator = null


func _on_eraser_width_changed(value):
	operator.stroke_width = value


func _on_opacity_changed(value):
	operator.alpha = value / 100.0


func _on_stroke_dynamics(index):
	match index:
		0:
			operator.dynamics_stroke_width = Dynamics.NONE
			operator.dynamics_stroke_alpha = Dynamics.NONE
		1:
			operator.dynamics_stroke_width = Dynamics.PRESSURE
			operator.dynamics_stroke_alpha = Dynamics.PRESSURE
		2:
			operator.dynamics_stroke_width = Dynamics.VELOCITY
			operator.dynamics_stroke_alpha = Dynamics.VELOCITY
