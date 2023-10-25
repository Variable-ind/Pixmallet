class_name PropShading extends VBoxContainer

var operator :Variant
	
@onready var stroke_width := $StrokeWidth

@onready var opt_lighten := $OptLighten
@onready var opt_simple := $OptSimpleShading

@onready var opt_amount := $Amount
@onready var opt_hue_amount := $Hue
@onready var opt_sat_amount := $Saturation
@onready var opt_value_amount := $Value


func subscribe(new_operator:ShadingDrawer):
	unsubscribe()
	operator = new_operator
	stroke_width.min_value = operator.STROKE_WIDTH_MIN
	stroke_width.max_value = operator.STROKE_WIDTH_MAX
	stroke_width.value = operator.stroke_width  # max/min defined in operator.

	opt_simple.selected = 0 if operator.opt_simple_shading else 1
	opt_lighten.selected = 0 if operator.opt_lighten else 1
	opt_amount.value = operator.opt_amount
	opt_hue_amount.value = operator.opt_hue_amount
	opt_sat_amount.value = operator.opt_sat_amount
	opt_value_amount.value = operator.opt_value_amount
	
	opt_amount.visible = operator.opt_simple_shading
	opt_hue_amount.visible = not operator.opt_simple_shading
	opt_sat_amount.visible = not operator.opt_simple_shading
	opt_value_amount.visible = not operator.opt_simple_shading
	
	stroke_width.value_changed.connect(_on_stroke_width_changed)
	opt_simple.item_selected.connect(_on_simple_shading_selected)
	opt_lighten.item_selected.connect(_on_lighten_selected)
	opt_amount.value_changed.connect(_on_amount_changed)
	opt_hue_amount.value_changed.connect(_on_hue_amount_changed)
	opt_sat_amount.value_changed.connect(_on_sat_amount_changed)
	opt_value_amount.value_changed.connect(_on_value_amount_changed)


func unsubscribe():
	if stroke_width.value_changed.is_connected(_on_stroke_width_changed):
		stroke_width.value_changed.disconnect(_on_stroke_width_changed)
	if opt_simple.item_selected.is_connected(_on_simple_shading_selected):
		opt_simple.item_selected.disconnect(_on_simple_shading_selected)
	if opt_lighten.item_selected.is_connected(_on_lighten_selected):
		opt_lighten.item_selected.disconnect(_on_lighten_selected)
	if opt_amount.value_changed.is_connected(_on_amount_changed):
		opt_amount.value_changed.disconnect(_on_amount_changed)
	if opt_hue_amount.value_changed.is_connected(_on_hue_amount_changed):
		opt_hue_amount.value_changed.disconnect(_on_hue_amount_changed)
	if opt_sat_amount.value_changed.is_connected(_on_sat_amount_changed):
		opt_sat_amount.value_changed.disconnect(_on_sat_amount_changed)
	if opt_value_amount.value_changed.is_connected(_on_value_amount_changed):
		opt_value_amount.value_changed.disconnect(_on_value_amount_changed)
	operator = null


func _on_stroke_width_changed(value):
	operator.stroke_width = value


func _on_simple_shading_selected(index):
	operator.opt_simple_shading = index == 0
	opt_amount.visible = operator.opt_simple_shading
	opt_hue_amount.visible = not operator.opt_simple_shading
	opt_sat_amount.visible = not operator.opt_simple_shading
	opt_value_amount.visible = not operator.opt_simple_shading

 
func _on_lighten_selected(index):
	operator.opt_lighten = index == 0


func _on_amount_changed(value):
	operator.opt_amount = value
	

func _on_hue_amount_changed(value):
	operator.opt_hue_amount = value
	

func _on_sat_amount_changed(value):
	operator.opt_sat_amount = value


func _on_value_amount_changed(value):
	operator.opt_value_amount = value
