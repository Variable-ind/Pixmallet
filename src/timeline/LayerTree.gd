class_name LayerTree extends VBoxContainer

var layers :Array[BaseLayer] = []

var selected_layer_bars :Array[LayerBar] = []
var layer_bars :Array[LayerBar] = []

@onready var layer_bar :LayerBar = $LayerBarTMPL
@onready var column := $column


func attach(proj_layers:Array[BaseLayer]):
	layers = proj_layers
	for ly in layers:
		var new_layer := layer_bar.duplicate()
		column.add_child(new_layer)
		new_layer.attach(ly)
		layer_bars.append(new_layer)


func _get_drag_data(pos: Vector2):
#	if layers_column.get_global_rect()
#	var box := HBoxContainer.new()
#	for sel_layer in selected_layers:
#		box.add_child(sel_layer)
#	set_drag_preview(box)

	return selected_layer_bars


func _can_drop_data(pos: Vector2, _data) -> bool:
	return true


func _drop_data(pos: Vector2, data) -> void:
	print(pos, data)

